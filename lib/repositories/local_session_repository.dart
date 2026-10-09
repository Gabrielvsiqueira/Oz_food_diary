import '../database/app_database.dart';
import '../database/ids.dart';
import '../mocks/mock_daily_logs.dart';
import '../mocks/mock_user_profile.dart';
import '../models/meal.dart';
import '../services/nutrition_calculator.dart';
import 'meal_repository.dart';
import 'profile_repository.dart';
import 'session_repository.dart';

/// Sessão sem servidor, até a autenticação real (Supabase Auth): há sessão
/// enquanto existir um perfil salvo no aparelho. O login aceita qualquer
/// e-mail/senha válidos e, sem perfil salvo, entra numa conta de
/// demonstração.
class LocalSessionRepository implements SessionRepository {
  const LocalSessionRepository(
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
  Future<bool> hasSession() async => await profiles.load() != null;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (await hasSession()) return;
    await profiles.create(
      mockUserProfile,
      calculator.calculateGoal(mockUserProfile),
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
  }

  @override
  Future<void> signOut() => _db.clearUserData();
}
