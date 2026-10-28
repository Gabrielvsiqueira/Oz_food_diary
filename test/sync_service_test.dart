import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/mocks/mock_user_profile.dart';
import 'package:oz_contador_de_calorias/models/enums/meal_type.dart';
import 'package:oz_contador_de_calorias/models/enums/portion_unit.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/models/meal.dart';
import 'package:oz_contador_de_calorias/models/meal_item.dart';
import 'package:oz_contador_de_calorias/models/nutrition_goal.dart';
import 'package:oz_contador_de_calorias/models/sync_failure.dart';
import 'package:oz_contador_de_calorias/repositories/drift_meal_repository.dart';
import 'package:oz_contador_de_calorias/repositories/drift_profile_repository.dart';
import 'package:oz_contador_de_calorias/services/date_utils.dart';
import 'package:oz_contador_de_calorias/services/sync_service.dart';

import 'support/fake_sync_remote.dart';

/// Um aparelho: banco local próprio, falando com o servidor falso.
class _Device {
  _Device(FakeSyncServer server, String userId, {int pageSize = 500})
    : db = AppDatabase(
        NativeDatabase.memory(),
        foodSeed: () async => MockFoods.all,
      ),
      remote = server.client(userId) as FakeSyncRemote,
      userId = userId {
    sync = SyncService(db, remote, pageSize: pageSize);
  }

  final AppDatabase db;
  final FakeSyncRemote remote;
  final String userId;
  late final SyncService sync;

  DriftMealRepository get meals => DriftMealRepository(db);
  DriftProfileRepository get profiles => DriftProfileRepository(db);

  Future<SyncResult> run() => sync.sync(userId);

  Future<List<Meal>> mealsToday() => meals.watchMealsOn(today()).first;
}

void main() {
  // Cada aparelho tem o próprio banco em memória.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const userId = '11111111-1111-1111-1111-111111111111';
  const goal = NutritionGoal(
    caloriesTarget: 2000,
    carbsTargetG: 200,
    proteinTargetG: 150,
    fatTargetG: 60,
  );
  const rice = MealItem(
    food: MockFoods.whiteRice,
    portion: FoodPortion(PortionUnit.tablespoon, 25),
    quantity: 4,
  );
  const beans = MealItem(
    food: MockFoods.pintoBeans,
    portion: FoodPortion(PortionUnit.ladle, 86),
    quantity: 1,
  );
  final lunchTime = DateTime.now().copyWith(hour: 12, minute: 30);

  Meal lunch(List<MealItem> items, {MealType type = MealType.lunch}) =>
      Meal(id: 'meal-1', type: type, items: items, createdAt: lunchTime);

  late FakeSyncServer server;
  late _Device phone;
  late _Device tablet;

  setUp(() {
    server = FakeSyncServer();
    phone = _Device(server, userId);
    tablet = _Device(server, userId);
  });

  tearDown(() async {
    await phone.db.close();
    await tablet.db.close();
  });

  /// Garante `updated_at` diferentes entre duas edições seguidas.
  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 2));

  test('envia o que está pendente e desmarca', () async {
    await phone.profiles.create(mockUserProfile, goal, userId: userId);
    await phone.meals.save(lunch(const [rice, beans]));
    expect(await phone.db.pendingCount(), 6);

    final result = await phone.run();

    expect(result.pushed, 6);
    expect(await phone.db.pendingCount(), 0);
    expect(server.rows('meals').single['type'], 'lunch');
    expect(server.rows('meal_items'), hasLength(2));
    expect(server.rows('meal_items').first['kcal_100g'], isNotNull);
    expect(server.rows('meals').single['user_id'], userId);
  });

  test('sem pendências, não chama o envio', () async {
    await phone.run();
    expect(phone.remote.pushes, 0);
  });

  test('outro aparelho baixa perfil, metas e refeições', () async {
    await phone.profiles.create(mockUserProfile, goal, userId: userId);
    await phone.meals.save(lunch(const [rice, beans]));
    await phone.run();

    final result = await tablet.run();

    expect(result.profileChanged, isTrue);
    final data = (await tablet.profiles.load())!;
    expect(data.profile.name, mockUserProfile.name);
    expect(data.profile.birthDate, mockUserProfile.birthDate);
    expect(data.profile.weight, mockUserProfile.weight);
    expect(data.goal.caloriesTarget, 2000);
    final [meal] = await tablet.mealsToday();
    expect(meal.createdAt, lunchTime);
    expect(meal.items.map((i) => i.food.name), [
      'Arroz branco cozido',
      'Feijão carioca cozido',
    ]);
    expect(meal.calories, lunch(const [rice, beans]).calories);
    expect(await tablet.db.pendingCount(), 0);
  });

  test('exclusão em um aparelho some do outro', () async {
    await phone.meals.save(lunch(const [rice]));
    await phone.run();
    await tablet.run();
    expect(await tablet.mealsToday(), hasLength(1));

    await phone.meals.delete(lunch(const [rice]));
    await phone.run();
    await tablet.run();

    expect(await tablet.mealsToday(), isEmpty);
  });

  test('a edição mais recente vence, nos dois sentidos', () async {
    await phone.meals.save(lunch(const [rice]));
    await phone.run();
    await tablet.run();

    // O tablet edita offline; depois o celular edita e sincroniza primeiro.
    await tablet.meals.save(lunch(const [rice], type: MealType.dinner));
    await tick();
    await phone.meals.save(lunch(const [rice], type: MealType.snack));
    await phone.run();

    // O envio do tablet é mais antigo: o servidor ignora e o download traz
    // a versão do celular.
    await tablet.run();
    expect((await tablet.mealsToday()).single.type, MealType.snack);
    expect(await tablet.db.pendingCount(), 0);

    // Agora o tablet edita por último e vence no celular.
    await tick();
    await tablet.meals.save(lunch(const [rice], type: MealType.breakfast));
    await tablet.run();
    await phone.run();
    expect((await phone.mealsToday()).single.type, MealType.breakfast);
  });

  test('edição local mais nova não é sobrescrita pelo download', () async {
    await phone.meals.save(lunch(const [rice]));
    await phone.run();
    await tablet.run();

    await phone.meals.save(lunch(const [rice], type: MealType.snack));
    await phone.run();
    await tick();
    await tablet.meals.save(lunch(const [rice], type: MealType.dinner));
    // Falha só o envio: o download roda com a edição ainda pendente.
    tablet.remote.failNext = const SyncOfflineFailure();
    await expectLater(tablet.run(), throwsA(isA<SyncOfflineFailure>()));

    await tablet.run();

    expect((await tablet.mealsToday()).single.type, MealType.dinner);
    expect(server.rows('meals').single['type'], 'dinner');
  });

  test('edição feita durante o envio continua pendente', () async {
    await phone.meals.save(lunch(const [rice]));
    phone.remote.onPush = () async {
      phone.remote.onPush = null;
      await tick();
      await phone.meals.save(lunch(const [rice], type: MealType.dinner));
    };

    await phone.run();

    expect(server.rows('meals').single['type'], 'lunch');
    expect(await phone.db.pendingCount(), greaterThan(0));
    await phone.run();
    expect(server.rows('meals').single['type'], 'dinner');
    expect(await phone.db.pendingCount(), 0);
  });

  test('sem internet, os dados continuam pendentes', () async {
    await phone.meals.save(lunch(const [rice]));
    phone.remote.failNext = const SyncOfflineFailure();

    await expectLater(phone.run(), throwsA(isA<SyncOfflineFailure>()));

    expect(await phone.db.pendingCount(), 2);
    expect(server.rows('meals'), isEmpty);
  });

  test('baixa em páginas e retoma do cursor', () async {
    final pagedTablet = _Device(server, userId, pageSize: 2);
    addTearDown(pagedTablet.db.close);
    for (var i = 0; i < 5; i++) {
      await phone.meals.save(
        Meal(
          id: 'meal-$i',
          type: MealType.snack,
          items: const [rice],
          createdAt: lunchTime,
        ),
      );
    }
    await phone.run();

    await pagedTablet.run();
    expect(await pagedTablet.mealsToday(), hasLength(5));

    // O segundo download só repete a margem de segurança, sem regravar.
    final again = await pagedTablet.run();
    expect(again.pulled, 0);
    expect(
      await pagedTablet.db.select(pagedTablet.db.syncState).get(),
      hasLength(2),
    );
  });

  test('ao sair, o cursor é apagado e o próximo login baixa tudo', () async {
    await phone.meals.save(lunch(const [rice]));
    await phone.run();
    await tablet.run();

    await tablet.db.clearUserData();
    expect(await tablet.db.select(tablet.db.syncState).get(), isEmpty);

    await tablet.run();
    expect(await tablet.mealsToday(), hasLength(1));
  });

  test('para de gravar quando o usuário sai no meio', () async {
    await phone.meals.save(lunch(const [rice]));
    await phone.run();

    var active = true;
    final result = tablet.sync.sync(userId, isActive: () => active);
    active = false;
    await result;

    expect(await tablet.db.select(tablet.db.meals).get(), isEmpty);
  });

  test('banco da versão 1 ganha a tabela do cursor', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        raw.execute('PRAGMA user_version = 1');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    // Sem a migração, falharia com "no such table: sync_state".
    expect(await db.select(db.syncState).get(), isEmpty);
  });
}
