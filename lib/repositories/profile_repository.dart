import '../models/nutrition_goal.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';

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

  /// Registra o peso de [day] (no máximo uma medição por dia: substitui a
  /// que existir). O peso atual do perfil é sempre o da medição mais recente.
  Future<void> saveWeight(DateTime day, double weightKg);

  /// Salva a meta vigente a partir de hoje, mantendo o histórico.
  Future<void> saveGoal(NutritionGoal goal);

  /// Medições de peso da mais antiga para a mais recente, atualizadas a cada
  /// gravação (inclusive as que chegam pela sincronização).
  Stream<List<WeightEntry>> watchWeightHistory();
}
