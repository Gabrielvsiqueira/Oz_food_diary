import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/date_only_converter.dart';
import '../database/ids.dart';
import '../models/nutrition_goal.dart';
import '../models/user_profile.dart';
import '../services/date_utils.dart';
import 'profile_repository.dart';

class DriftProfileRepository implements ProfileRepository {
  const DriftProfileRepository(this._db);

  final AppDatabase _db;

  @override
  Future<ProfileData?> load() async {
    final profile = await _profileRow();
    final weight = await _latestWeight();
    final goal = await _currentGoal();
    if (profile == null || weight == null || goal == null) return null;
    return (
      profile: UserProfile(
        name: profile.name,
        goal: profile.goal,
        gender: profile.gender,
        birthDate: profile.birthDate,
        activityLevel: profile.activityLevel,
        height: profile.heightCm,
        weight: weight.weightKg,
      ),
      goal: NutritionGoal(
        caloriesTarget: goal.calories,
        carbsTargetG: goal.carbsG,
        proteinTargetG: goal.proteinG,
        fatTargetG: goal.fatG,
      ),
    );
  }

  @override
  Future<void> create(UserProfile profile, NutritionGoal goal) =>
      _db.transaction(() async {
        await _db.clearUserData();
        final now = DateTime.now().toUtc();
        final userId = newId();
        await _db
            .into(_db.profiles)
            .insert(
              ProfilesCompanion.insert(
                id: userId,
                name: profile.name,
                goal: profile.goal,
                gender: profile.gender,
                birthDate: profile.birthDate,
                activityLevel: profile.activityLevel,
                heightCm: profile.height,
                createdAt: now,
                updatedAt: now,
              ),
            );
        await _saveWeight(userId, profile.weight);
        await _saveGoal(userId, goal);
      });

  @override
  Future<void> updateProfile(UserProfile profile) => _db.transaction(() async {
    final row = await _requireProfile();
    await (_db.update(_db.profiles)..where((p) => p.id.equals(row.id))).write(
      ProfilesCompanion(
        name: Value(profile.name),
        goal: Value(profile.goal),
        gender: Value(profile.gender),
        birthDate: Value(profile.birthDate),
        activityLevel: Value(profile.activityLevel),
        heightCm: Value(profile.height),
        updatedAt: Value(DateTime.now().toUtc()),
        isDirty: const Value(true),
      ),
    );
    if ((await _latestWeight())?.weightKg != profile.weight) {
      await _saveWeight(row.id, profile.weight);
    }
  });

  @override
  Future<void> saveGoal(NutritionGoal goal) => _db.transaction(() async {
    await _saveGoal((await _requireProfile()).id, goal);
  });

  Future<ProfileRow?> _profileRow() =>
      (_db.select(_db.profiles)
            ..where((p) => p.deletedAt.isNull())
            ..limit(1))
          .getSingleOrNull();

  Future<ProfileRow> _requireProfile() async =>
      await _profileRow() ?? (throw StateError('Nenhum perfil salvo'));

  Future<WeightEntryRow?> _latestWeight() =>
      (_db.select(_db.weightEntries)
            ..where((w) => w.deletedAt.isNull())
            ..orderBy([(w) => OrderingTerm.desc(w.measuredOn)])
            ..limit(1))
          .getSingleOrNull();

  /// Meta com a maior data de início até hoje (ou a mais recente, se o
  /// relógio do aparelho voltou no tempo). Datas `AAAA-MM-DD` ordenam
  /// corretamente como texto.
  Future<NutritionGoalRow?> _currentGoal() async {
    final todayText = const DateOnlyConverter().toSql(today());
    Future<NutritionGoalRow?> latest({required bool untilToday}) =>
        (_db.select(_db.nutritionGoals)
              ..where(
                (g) =>
                    g.deletedAt.isNull() &
                    (untilToday
                        ? g.effectiveFrom.isSmallerOrEqualValue(todayText)
                        : const Constant(true)),
              )
              ..orderBy([(g) => OrderingTerm.desc(g.effectiveFrom)])
              ..limit(1))
            .getSingleOrNull();
    return await latest(untilToday: true) ?? await latest(untilToday: false);
  }

  Future<void> _saveWeight(String userId, double weightKg) {
    final now = DateTime.now().toUtc();
    final day = today();
    return _db
        .into(_db.weightEntries)
        .insert(
          WeightEntriesCompanion.insert(
            id: dailyRecordId(userId, 'weight', day),
            measuredOn: day,
            weightKg: weightKg,
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => WeightEntriesCompanion(
              weightKg: Value(weightKg),
              updatedAt: Value(now),
              deletedAt: const Value(null),
              isDirty: const Value(true),
            ),
          ),
        );
  }

  Future<void> _saveGoal(String userId, NutritionGoal goal) {
    final now = DateTime.now().toUtc();
    final day = today();
    final values = NutritionGoalsCompanion(
      calories: Value(goal.caloriesTarget),
      carbsG: Value(goal.carbsTargetG),
      proteinG: Value(goal.proteinTargetG),
      fatG: Value(goal.fatTargetG),
      updatedAt: Value(now),
      deletedAt: const Value(null),
      isDirty: const Value(true),
    );
    return _db
        .into(_db.nutritionGoals)
        .insert(
          values.copyWith(
            id: Value(dailyRecordId(userId, 'goal', day)),
            effectiveFrom: Value(day),
            createdAt: Value(now),
          ),
          onConflict: DoUpdate((_) => values),
        );
  }
}
