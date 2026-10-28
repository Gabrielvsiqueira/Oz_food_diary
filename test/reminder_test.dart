import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/controllers/reminder_controller.dart';
import 'package:oz_contador_de_calorias/controllers/session_controller.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/models/enums/meal_type.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/models/meal.dart';
import 'package:oz_contador_de_calorias/models/meal_item.dart';
import 'package:oz_contador_de_calorias/models/meal_reminder.dart';
import 'package:oz_contador_de_calorias/models/session_user.dart';
import 'package:oz_contador_de_calorias/repositories/drift_reminder_repository.dart';
import 'package:oz_contador_de_calorias/repositories/mock_meal_repository.dart';
import 'package:oz_contador_de_calorias/repositories/session_repository.dart';
import 'package:oz_contador_de_calorias/services/reminder_planner.dart';
import 'package:oz_contador_de_calorias/services/reminder_scheduler.dart';

class _Session implements SessionRepository {
  @override
  Stream<void> get sessionRevoked => const Stream.empty();

  @override
  Future<SessionUser?> currentUser() async => null;

  @override
  Future<SessionUser> signIn({
    required String email,
    required String password,
  }) async => const SessionUser(id: 'user-1');

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeScheduler implements ReminderScheduler {
  List<PlannedReminder>? scheduled;
  var granted = false;
  var permissionRequests = 0;
  var cancels = 0;

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return granted = true;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async =>
      scheduled = reminders;

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled = const [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Terça, 10h: o café (8h) de hoje já passou.
  final now = DateTime(2026, 10, 27, 10);

  group('planReminders', () {
    List<PlannedReminder> plan({Set<MealType> logged = const {}}) =>
        planReminders(
          reminders: MealReminder.defaults,
          now: now,
          loggedToday: logged,
        );

    test('agenda 7 dias, sem horários que já passaram nem os desligados', () {
      final planned = plan();

      // Hoje: almoço e jantar. Depois, 6 dias × 3 refeições ligadas.
      expect(planned, hasLength(2 + 6 * 3));
      expect(planned.first.when, DateTime(2026, 10, 27, 12, 30));
      expect(planned.last.when, DateTime(2026, 11, 2, 19, 30));
      expect(planned.where((p) => p.type == MealType.snack), isEmpty);
      expect(planned.map((p) => p.id).toSet(), hasLength(planned.length));
    });

    test('pula o lembrete de hoje de uma refeição já registrada', () {
      final planned = plan(logged: {MealType.lunch});

      expect(
        planned.where((p) => p.type == MealType.lunch).first.when,
        DateTime(2026, 10, 28, 12, 30),
        reason: 'amanhã continua',
      );
    });

    test('fica abaixo do limite de 64 do iOS com tudo ligado', () {
      final all = [
        for (final r in MealReminder.defaults) r.copyWith(enabled: true),
      ];
      expect(
        planReminders(
          reminders: all,
          now: DateTime(2026, 10, 27),
          loggedToday: const {},
        ).length,
        lessThanOrEqualTo(64),
      );
    });
  });

  group('DriftReminderRepository', () {
    late AppDatabase db;
    late DriftReminderRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = DriftReminderRepository(db);
    });

    tearDown(() => db.close());

    test('sem nada salvo, usa o padrão', () async {
      final reminders = await repository.load();
      expect(reminders.map((r) => r.type), MealType.values.toSet());
      expect(reminders.firstWhere((r) => r.type == MealType.lunch).minute, 30);
    });

    test('guarda o horário e o liga/desliga', () async {
      await repository.save(
        const MealReminder(
          type: MealType.snack,
          enabled: true,
          hour: 15,
          minute: 45,
        ),
      );

      final snack = (await repository.load()).firstWhere(
        (r) => r.type == MealType.snack,
      );
      expect((snack.enabled, snack.hour, snack.minute), (true, 15, 45));
    });

    test('sair da conta volta ao padrão', () async {
      await repository.save(
        MealReminder.defaults.first.copyWith(enabled: false),
      );
      await db.clearUserData();
      expect((await repository.load()).first.enabled, isTrue);
    });

    test('banco da versão 3 ganha a tabela dos lembretes', () async {
      final old = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) => raw.execute('PRAGMA user_version = 3'),
        ),
      );
      addTearDown(old.close);
      expect(await old.select(old.reminderSettings).get(), isEmpty);
    });
  });

  group('ReminderController', () {
    late AppDatabase db;
    late MockMealRepository meals;
    late SessionController session;
    late _FakeScheduler scheduler;
    late ReminderController controller;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      meals = MockMealRepository();
      session = SessionController(_Session());
      scheduler = _FakeScheduler();
      controller = ReminderController(
        session: session,
        repository: DriftReminderRepository(db),
        scheduler: scheduler,
        meals: meals,
        now: () => now,
      );
    });

    tearDown(() async {
      controller.dispose();
      session.dispose();
      await db.close();
    });

    Future<void> signIn() async {
      await session.login(email: 'a@b.com', password: '12345678');
      await pumpEventQueue();
    }

    Iterable<DateTime> today(MealType type) => scheduler.scheduled!
        .where((p) => p.type == type && p.when.day == now.day)
        .map((p) => p.when);

    test('sem sessão, não agenda nada', () async {
      await pumpEventQueue();
      expect(scheduler.scheduled, isNull);
    });

    test('ao entrar, agenda os próximos 7 dias', () async {
      await signIn();

      expect(scheduler.scheduled, hasLength(20));
      expect(controller.permissionGranted, isFalse);
    });

    test('registrar o almoço de hoje tira só o lembrete de hoje', () async {
      await signIn();
      expect(today(MealType.lunch), isNotEmpty);

      await meals.save(
        Meal(
          id: 'meal-1',
          type: MealType.lunch,
          items: const [
            MealItem(
              food: MockFoods.egg,
              portion: FoodPortion.gram,
              quantity: 50,
            ),
          ],
          createdAt: now,
        ),
      );
      await pumpEventQueue();

      expect(today(MealType.lunch), isEmpty);
      expect(today(MealType.dinner), isNotEmpty);
    });

    test('mudar o horário reagenda e fica salvo', () async {
      await signIn();

      await controller.setTime(MealType.dinner, hour: 21, minute: 15);

      expect(today(MealType.dinner), [DateTime(2026, 10, 27, 21, 15)]);
      final saved = await DriftReminderRepository(db).load();
      expect(saved.firstWhere((r) => r.type == MealType.dinner).hour, 21);
    });

    test('ligar um lembrete sem permissão pede a permissão', () async {
      await signIn();

      await controller.setEnabled(MealType.snack, enabled: true);

      expect(scheduler.permissionRequests, 1);
      expect(controller.permissionGranted, isTrue);
      expect(today(MealType.snack), [DateTime(2026, 10, 27, 16)]);
    });

    test('desligar tira o lembrete de todos os dias', () async {
      await signIn();

      await controller.setEnabled(MealType.breakfast, enabled: false);

      expect(
        scheduler.scheduled!.where((p) => p.type == MealType.breakfast),
        isEmpty,
      );
      expect(scheduler.permissionRequests, 0);
    });

    test('ao sair, cancela tudo e para de agendar', () async {
      await signIn();

      await session.logout();
      await pumpEventQueue();

      expect(scheduler.cancels, 1);
      expect(scheduler.scheduled, isEmpty);
      await controller.setTime(MealType.lunch, hour: 13, minute: 0);
      expect(scheduler.scheduled, isEmpty);
    });
  });
}
