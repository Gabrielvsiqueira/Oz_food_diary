import 'dart:async';

import '../database/app_database.dart';
import '../database/ids.dart';
import '../mocks/mock_daily_logs.dart';
import '../mocks/mock_user_profile.dart';
import '../models/auth_failure.dart';
import '../models/meal.dart';
import '../models/session_user.dart';
import '../services/nutrition_calculator.dart';
import 'meal_repository.dart';
import 'profile_repository.dart';
import 'session_repository.dart';

/// Sessão sem servidor, usada quando o Supabase não está configurado: há
/// sessão enquanto existir um perfil salvo no aparelho. O login aceita
/// qualquer e-mail/senha válidos e, sem perfil salvo, entra numa conta de
/// demonstração.
class LocalSessionRepository implements SessionRepository {
  LocalSessionRepository(
    this._db, {
    required this.profiles,
    required this.meals,
    this.calculator = const NutritionCalculator(),
  });

  final AppDatabase _db;
  final ProfileRepository profiles;
  final MealRepository meals;
  final NutritionCalculator calculator;

  @override
  Stream<void> get sessionRevoked => const Stream.empty();

  @override
  Future<SessionUser?> currentUser() async {
    final row = await (_db.select(_db.profiles)..limit(1)).getSingleOrNull();
    return row == null ? null : SessionUser(id: row.id, name: row.name);
  }

  @override
  Future<SessionUser> signIn({
    required String email,
    required String password,
  }) async {
    final existing = await currentUser();
    if (existing != null) return existing;
    final user = SessionUser(id: newId(), email: email);
    await profiles.create(
      mockUserProfile,
      calculator.calculateGoal(mockUserProfile),
      userId: user.id,
    );
    for (final log in buildMockDailyLogs()) {
      for (final meal in log.meals) {
        await meals.save(
          Meal(
            id: newId(),
            type: meal.type,
            items: meal.items,
            createdAt: meal.createdAt,
          ),
        );
      }
    }
    return user;
  }

  @override
  Future<SessionUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async => SessionUser(id: newId(), name: name, email: email);

  @override
  Future<SessionUser> signInWithGoogle() =>
      Future.error(const ProviderUnavailableFailure());

  @override
  Future<void> signOut() => _db.clearUserData();

  @override
  Future<void> deleteAccount() => _db.clearUserData();
}
