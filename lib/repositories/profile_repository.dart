import '../models/nutrition_goal.dart';
import '../models/user_profile.dart';

typedef ProfileData = ({UserProfile profile, NutritionGoal goal});

abstract interface class ProfileRepository {
  Future<ProfileData?> load();

  /// Cria o perfil a partir do onboarding, substituindo qualquer dado
  /// anterior do aparelho. [userId] é o id do usuário autenticado.
  Future<void> create(
    UserProfile profile,
    NutritionGoal goal, {
    required String userId,
  });

  /// Salva o perfil; um peso diferente vira a medição de hoje.
  Future<void> updateProfile(UserProfile profile);

  /// Salva a meta vigente a partir de hoje, mantendo o histórico.
  Future<void> saveGoal(NutritionGoal goal);
}
