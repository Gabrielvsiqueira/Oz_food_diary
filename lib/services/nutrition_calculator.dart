import 'dart:math';

import '../configs/constants/nutrition_constants.dart';
import '../models/enums/gender.dart';
import '../models/nutrition_goal.dart';
import '../models/user_profile.dart';

class NutritionCalculator {
  const NutritionCalculator();

  /// Taxa metabólica basal (Mifflin-St Jeor).
  double basalMetabolicRate(UserProfile profile) {
    final base = 10 * profile.weight + 6.25 * profile.height - 5 * profile.age;
    return profile.gender == Gender.male ? base + 5 : base - 161;
  }

  /// Gasto energético total = TMB × fator de atividade.
  double totalDailyEnergyExpenditure(UserProfile profile) {
    final factor = NutritionConstants.activityFactors[profile.activityLevel]!;
    return basalMetabolicRate(profile) * factor;
  }

  NutritionGoal calculateGoal(UserProfile profile) {
    final adjustment = NutritionConstants.goalCalorieAdjustments[profile.goal]!;
    final calories = (totalDailyEnergyExpenditure(profile) + adjustment)
        .round();

    final protein = NutritionConstants.proteinGramsPerKg * profile.weight;
    final fat =
        calories *
        NutritionConstants.fatCaloriesShare /
        NutritionConstants.kcalPerGramFat;
    final remaining =
        calories -
        protein * NutritionConstants.kcalPerGramProtein -
        fat * NutritionConstants.kcalPerGramFat;
    final carbs = max(0.0, remaining / NutritionConstants.kcalPerGramCarbs);

    return NutritionGoal(
      caloriesTarget: calories,
      carbsTargetG: carbs.roundToDouble(),
      proteinTargetG: protein.roundToDouble(),
      fatTargetG: fat.roundToDouble(),
    );
  }

  double caloriesFromMacros({
    required double carbsG,
    required double proteinG,
    required double fatG,
  }) {
    return carbsG * NutritionConstants.kcalPerGramCarbs +
        proteinG * NutritionConstants.kcalPerGramProtein +
        fatG * NutritionConstants.kcalPerGramFat;
  }
}
