import '../../models/enums/activity_level.dart';
import '../../models/enums/goal_type.dart';

class NutritionConstants {
  NutritionConstants._();

  static const double kcalPerGramCarbs = 4;
  static const double kcalPerGramProtein = 4;
  static const double kcalPerGramFat = 9;

  static const Map<ActivityLevel, double> activityFactors = {
    ActivityLevel.sedentary: 1.2,
    ActivityLevel.light: 1.375,
    ActivityLevel.moderate: 1.55,
    ActivityLevel.heavy: 1.725,
    ActivityLevel.athlete: 1.9,
  };

  static const Map<GoalType, int> goalCalorieAdjustments = {
    GoalType.lose: -500,
    GoalType.maintain: 0,
    GoalType.gain: 300,
  };

  static const double proteinGramsPerKg = 2.2;
  static const double fatCaloriesShare = 0.25;

  /// Diferença máxima aceita entre as calorias informadas e as calculadas
  /// a partir dos macros (0.10 = 10%).
  static const double mealCaloriesTolerance = 0.10;

  static const double minHeightCm = 100;
  static const double maxHeightCm = 250;
  static const double minWeightKg = 30;
  static const double maxWeightKg = 300;
  static const int minAge = 13;
  static const int maxAge = 100;
}
