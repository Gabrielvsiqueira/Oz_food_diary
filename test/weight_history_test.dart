import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:oz_contador_de_calorias/configs/strings/string_extensions.dart';
import 'package:oz_contador_de_calorias/controllers/profile_controller.dart';
import 'package:oz_contador_de_calorias/controllers/weight_history_controller.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/mocks/mock_user_profile.dart';
import 'package:oz_contador_de_calorias/models/enums/weight_period.dart';
import 'package:oz_contador_de_calorias/models/nutrition_goal.dart';
import 'package:oz_contador_de_calorias/models/user_profile.dart';
import 'package:oz_contador_de_calorias/models/weight_entry.dart';
import 'package:oz_contador_de_calorias/pages/evolution/evolution_page.dart';
import 'package:oz_contador_de_calorias/repositories/drift_profile_repository.dart';
import 'package:oz_contador_de_calorias/repositories/profile_repository.dart';
import 'package:oz_contador_de_calorias/services/date_utils.dart';
import 'package:provider/provider.dart';

/// Repositório com o histórico controlado pelo teste. Como no drift, uma
/// medição por dia, e o peso atual é o da mais recente.
class _FakeProfiles implements ProfileRepository {
  final history = StreamController<List<WeightEntry>>.broadcast();
  var entries = <WeightEntry>[];
  UserProfile profile = mockUserProfile;
  var goalsSaved = 0;

  void emit(List<WeightEntry> value) => history.add(entries = value);

  @override
  Stream<List<WeightEntry>> watchWeightHistory() => history.stream;

  @override
  Future<ProfileData?> load() async => (
    profile: entries.isEmpty
        ? profile
        : profile.copyWith(weightKg: entries.last.weightKg),
    goal: const NutritionGoal(
      caloriesTarget: 2000,
      carbsTargetG: 200,
      proteinTargetG: 150,
      fatTargetG: 60,
    ),
  );

  @override
  Future<void> saveWeight(DateTime day, double weightKg) async => emit(
    [
      for (final e in entries)
        if (e.date != day) e,
      WeightEntry(date: day, weightKg: weightKg),
    ]..sort((a, b) => a.date.compareTo(b.date)),
  );

  @override
  Future<void> saveGoal(NutritionGoal goal) async => goalsSaved++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  final day = DateTime(2026, 10, 28);
  DateTime daysAgo(int n) => day.subtract(Duration(days: n));
  WeightEntry entry(int daysBefore, double kg) =>
      WeightEntry(date: daysAgo(daysBefore), weightKg: kg);

  group('DriftProfileRepository.watchWeightHistory', () {
    late AppDatabase db;
    late DriftProfileRepository profiles;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      profiles = DriftProfileRepository(db);
      await profiles.create(
        mockUserProfile,
        const NutritionGoal(
          caloriesTarget: 2000,
          carbsTargetG: 200,
          proteinTargetG: 150,
          fatTargetG: 60,
        ),
        userId: '11111111-1111-1111-1111-111111111111',
      );
    });

    tearDown(() => db.close());

    Future<void> insertWeight(String id, DateTime on, double kg) => db
        .into(db.weightEntries)
        .insert(
          WeightEntriesCompanion.insert(
            id: id,
            measuredOn: on,
            weightKg: kg,
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );

    test(
      'lista da mais antiga para a mais recente, sem as excluídas',
      () async {
        await insertWeight(
          'w1',
          today().subtract(const Duration(days: 10)),
          80,
        );
        await insertWeight(
          'w2',
          today().subtract(const Duration(days: 20)),
          82,
        );
        await insertWeight('w3', today().subtract(const Duration(days: 5)), 79);
        await (db.update(db.weightEntries)..where((w) => w.id.equals('w3')))
            .write(WeightEntriesCompanion(deletedAt: Value(DateTime.now())));

        final history = await profiles.watchWeightHistory().first;

        expect(history.map((e) => e.weightKg), [
          82,
          80,
          mockUserProfile.weight,
        ]);
        expect(history.last.date, today());
      },
    );

    test(
      'peso de um dia anterior entra no histórico sem virar o atual',
      () async {
        final yesterday = today().subtract(const Duration(days: 1));
        await profiles.saveWeight(yesterday, 82);

        expect((await profiles.load())!.profile.weight, mockUserProfile.weight);
        final history = await profiles.watchWeightHistory().first;
        expect(history.map((e) => e.date), [yesterday, today()]);

        await profiles.saveWeight(yesterday, 81.5);
        expect(
          (await profiles.watchWeightHistory().first).first.weightKg,
          81.5,
          reason: 'mesmo dia: substitui',
        );
      },
    );

    test('salvar um peso novo no perfil atualiza o histórico', () async {
      final updates = profiles.watchWeightHistory();
      final seen = <List<double>>[];
      final subscription = updates.listen(
        (h) => seen.add([for (final e in h) e.weightKg]),
      );
      await pumpEventQueue();

      await profiles.updateProfile(mockUserProfile.copyWith(weightKg: 75.5));
      await pumpEventQueue();

      expect(seen.last, [75.5], reason: 'mesmo dia: substitui a medição');
      await subscription.cancel();
    });
  });

  group('WeightHistoryController', () {
    late _FakeProfiles repository;
    late WeightHistoryController controller;

    setUp(() {
      repository = _FakeProfiles();
      controller = WeightHistoryController(repository, today: () => day);
    });

    tearDown(() async {
      controller.dispose();
      await repository.history.close();
    });

    Future<void> emit(List<WeightEntry> entries) async {
      repository.emit(entries);
      await pumpEventQueue();
    }

    test('filtra pelo período, incluindo o primeiro dia dele', () async {
      await emit([entry(120, 90), entry(89, 86), entry(29, 84), entry(0, 83)]);

      expect(controller.isLoaded, isTrue);
      expect(controller.period, WeightPeriod.days30);
      expect(controller.visibleEntries.map((e) => e.weightKg), [84, 83]);
      expect(controller.change, closeTo(-1, 1e-9));

      controller.selectPeriod(WeightPeriod.days90);
      expect(controller.visibleEntries.map((e) => e.weightKg), [86, 84, 83]);

      controller.selectPeriod(WeightPeriod.all);
      expect(controller.visibleEntries, hasLength(4));
      expect(controller.change, closeTo(-7, 1e-9));
    });

    test('só uma medição não anterior à última vira o peso atual', () async {
      expect(controller.becomesCurrent(day), isTrue, reason: 'sem medições');
      await emit([entry(5, 80), entry(2, 79)]);

      expect(controller.latest!.weightKg, 79);
      expect(controller.becomesCurrent(daysAgo(3)), isFalse);
      expect(controller.becomesCurrent(daysAgo(2)), isTrue);
      expect(controller.becomesCurrent(day), isTrue);
    });

    test('com menos de duas medições não há variação', () async {
      await emit([entry(40, 80), entry(3, 81)]);
      expect(controller.visibleEntries, hasLength(1));
      expect(controller.change, isNull);
    });

    test('novas medições chegam pelo stream', () async {
      await emit([entry(3, 80)]);
      var notified = 0;
      controller.addListener(() => notified++);

      await emit([entry(3, 80), entry(0, 79.4)]);

      expect(notified, 1);
      expect(controller.change, closeTo(-0.6, 1e-9));
    });
  });

  test('formatSignedWeight usa sinal e uma casa decimal', () {
    expect(formatSignedWeight(1.5), '+1,5');
    expect(formatSignedWeight(-0.8), '−0,8');
    expect(formatSignedWeight(-2), '−2');
    expect(formatSignedWeight(0.04), '+0');
  });

  group('ProfileController.logWeight', () {
    late _FakeProfiles repository;
    late ProfileController profile;

    setUp(() async {
      repository = _FakeProfiles()..entries = [entry(0, 80)];
      profile = ProfileController(repository);
      await profile.load();
    });

    tearDown(() async {
      profile.dispose();
      await repository.history.close();
    });

    test('dia esquecido não muda o peso atual nem as metas', () async {
      await profile.logWeight(daysAgo(1), 83);

      expect(profile.profile.weight, 80);
      expect(repository.entries.map((e) => e.weightKg), [83, 80]);
      expect(repository.goalsSaved, 0);
    });

    test('medição mais recente vira o peso atual e recalcula', () async {
      await profile.logWeight(day, 78, recalculateGoal: true);

      expect(profile.profile.weight, 78);
      expect(repository.goalsSaved, 1);
    });
  });

  group('EvolutionPage', () {
    late _FakeProfiles repository;
    late ProfileController profile;

    setUp(() async {
      repository = _FakeProfiles();
      profile = ProfileController(repository);
      await profile.load();
    });

    tearDown(() async {
      profile.dispose();
      await repository.history.close();
    });

    Future<void> pumpPage(
      WidgetTester tester,
      List<WeightEntry> entries,
    ) async {
      tester.view
        ..physicalSize = const Size(800, 1600)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ProfileRepository>.value(value: repository),
            ChangeNotifierProvider.value(value: profile),
          ],
          child: const MaterialApp(home: EvolutionPage()),
        ),
      );
      repository.emit(entries);
      await tester.pump();
    }

    testWidgets('uma medição só mostra o aviso, sem gráfico', (tester) async {
      await pumpPage(tester, [WeightEntry(date: today(), weightKg: 80)]);

      expect(find.text(AppStrings.weightHistoryOnePoint), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
      expect(find.text('80 kg'), findsNWidgets(2), reason: 'resumo e lista');
    });

    testWidgets('duas medições mostram o gráfico, o resumo e a lista', (
      tester,
    ) async {
      await pumpPage(tester, [
        WeightEntry(
          date: today().subtract(const Duration(days: 7)),
          weightKg: 80,
        ),
        WeightEntry(date: today(), weightKg: 78.5),
      ]);

      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('−1,5 kg'), findsNWidgets(2), reason: 'resumo e lista');
      expect(find.text('78,5 kg'), findsNWidgets(2));
    });

    testWidgets('medições antigas somem no filtro de 30 dias', (tester) async {
      await pumpPage(tester, [
        WeightEntry(
          date: today().subtract(const Duration(days: 60)),
          weightKg: 85,
        ),
      ]);
      expect(find.text(AppStrings.weightHistoryEmptyPeriod), findsOneWidget);

      await tester.tap(find.text(AppStrings.weightPeriodAll));
      await tester.pump();
      expect(find.text(AppStrings.weightHistoryOnePoint), findsOneWidget);
    });

    testWidgets('registrar peso confirma, recalcula as metas e atualiza', (
      tester,
    ) async {
      await pumpPage(tester, [
        WeightEntry(
          date: today().subtract(const Duration(days: 3)),
          weightKg: mockUserProfile.weight,
        ),
      ]);

      await tester.tap(find.text(AppStrings.weightLogButton));
      await tester.pumpAndSettle();
      // 95 kg → 95,4 kg na roleta da casa decimal.
      await tester.drag(
        find.byType(CupertinoPicker).last,
        const Offset(0, -48.0 * 4),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.weightLogSave));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.profileRecalculateTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.commonYes));
      await tester.pumpAndSettle();

      expect(profile.profile.weight, 95.4);
      expect(repository.goalsSaved, 1);
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text(AppStrings.profileGoalsRecalculated), findsOneWidget);
    });
  });
}
