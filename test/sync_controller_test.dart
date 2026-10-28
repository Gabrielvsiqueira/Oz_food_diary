import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/controllers/session_controller.dart';
import 'package:oz_contador_de_calorias/controllers/sync_controller.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/models/enums/meal_type.dart';
import 'package:oz_contador_de_calorias/models/enums/sync_status.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/models/meal.dart';
import 'package:oz_contador_de_calorias/models/meal_item.dart';
import 'package:oz_contador_de_calorias/models/session_user.dart';
import 'package:oz_contador_de_calorias/models/sync_failure.dart';
import 'package:oz_contador_de_calorias/repositories/drift_meal_repository.dart';
import 'package:oz_contador_de_calorias/repositories/session_repository.dart';
import 'package:oz_contador_de_calorias/services/sync_service.dart';

import 'support/fake_sync_remote.dart';

const _userId = '11111111-1111-1111-1111-111111111111';

class _Session implements SessionRepository {
  SessionUser? user;

  @override
  Stream<void> get sessionRevoked => const Stream.empty();

  @override
  Future<SessionUser?> currentUser() async => user;

  @override
  Future<SessionUser> signIn({
    required String email,
    required String password,
  }) async => user = const SessionUser(id: _userId);

  @override
  Future<SessionUser> signUp({
    required String email,
    required String password,
    required String name,
  }) => signIn(email: email, password: password);

  @override
  Future<SessionUser> signInWithGoogle() => signIn(email: '', password: '');

  @override
  Future<void> signOut() async => user = null;

  @override
  Future<void> deleteAccount() => signOut();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late FakeSyncServer server;
  late FakeSyncRemote remote;
  late AppDatabase db;
  late SessionController session;
  late StreamController<bool> network;
  late SyncController sync;
  var profileReloads = 0;

  final snack = Meal(
    id: 'meal-1',
    type: MealType.snack,
    items: const [
      MealItem(food: MockFoods.egg, portion: FoodPortion.gram, quantity: 50),
    ],
    createdAt: DateTime.now(),
  );

  SyncController create({SyncService? service}) => SyncController(
    session: session,
    database: db,
    service: service,
    onProfileChanged: () async => profileReloads++,
    connectivity: network.stream,
    debounce: const Duration(milliseconds: 10),
  );

  setUp(() {
    server = FakeSyncServer();
    remote = server.client(_userId) as FakeSyncRemote;
    db = AppDatabase(NativeDatabase.memory());
    session = SessionController(_Session());
    network = StreamController<bool>();
    profileReloads = 0;
    sync = create(service: SyncService(db, remote));
  });

  tearDown(() async {
    sync.dispose();
    session.dispose();
    await network.close();
    await db.close();
  });

  Future<void> signIn() => session.login(email: 'a@b.com', password: 'x');

  /// Deixa rodar timers e chamadas assíncronas pendentes.
  Future<void> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sync.syncNow();
  }

  test('sem sessão, não sincroniza', () async {
    expect(await sync.syncNow(), isFalse);
    expect(remote.pushes, 0);
  });

  test('entrar na conta baixa os dados e recarrega o perfil', () async {
    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await DriftMealRepository(other).save(snack);
    await SyncService(other, remote).sync(_userId);

    await signIn();
    await settle();

    expect(await db.select(db.meals).get(), hasLength(1));
    expect(sync.status, SyncStatus.idle);
    expect(sync.lastSyncedAt, isNotNull);
    expect(profileReloads, 0, reason: 'só refeições mudaram');
  });

  test('gravação local sobe sozinha depois da espera', () async {
    await signIn();
    await settle();

    await DriftMealRepository(db).save(snack);
    await settle();

    expect(server.rows('meals'), hasLength(1));
    expect(sync.pendingCount, 0);
  });

  test(
    'sem internet, fica offline e tenta de novo quando a rede volta',
    () async {
      await signIn();
      await settle();
      remote.failNext = const SyncOfflineFailure();
      await DriftMealRepository(db).save(snack);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(sync.status, SyncStatus.offline);
      expect(sync.pendingCount, 2);

      network.add(true);
      await settle();

      expect(sync.status, SyncStatus.idle);
      expect(server.rows('meals'), hasLength(1));
    },
  );

  test('erro do servidor aparece como falha', () async {
    await signIn();
    await settle();
    remote.failNext = const SyncServerFailure('boom');

    expect(await sync.syncNow(), isFalse);
    expect(sync.status, SyncStatus.failed);
  });

  test('antes de sair, envia e informa o que ficou pendente', () async {
    await signIn();
    await settle();
    await DriftMealRepository(db).save(snack);
    expect(await sync.flushBeforeLogout(), 0);

    await DriftMealRepository(db).save(snack.copyWith(type: MealType.lunch));
    remote.failNext = const SyncOfflineFailure();
    expect(await sync.flushBeforeLogout(), greaterThan(0));
  });

  test('chamadas simultâneas usam a mesma sincronização', () async {
    await signIn();
    await settle();
    await DriftMealRepository(db).save(snack);

    final first = sync.syncNow();
    final second = sync.syncNow();
    expect(identical(first, second), isTrue);
    await first;
    expect(remote.pushes, 1);
  });

  test('sair para a sincronização', () async {
    await signIn();
    await settle();
    sync.stop();
    await session.logout();

    expect(await sync.syncNow(), isFalse);
    expect(sync.status, SyncStatus.idle);
  });

  test('sem servidor configurado, fica desligado', () async {
    sync.dispose();
    sync = create();
    await signIn();

    expect(sync.isEnabled, isFalse);
    expect(await sync.syncNow(), isTrue);
    expect(await sync.flushBeforeLogout(), 0);
  });
}
