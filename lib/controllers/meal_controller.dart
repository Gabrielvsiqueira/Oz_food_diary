import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/meal_type.dart';
import '../models/meal.dart';
import '../services/nutrition_calculator.dart';
import '../services/validators.dart';
import 'daily_log_controller.dart';

/// CRUD de refeições. Recebe o [DailyLogController] via
/// `ChangeNotifierProxyProvider` e delega a ele o armazenamento por dia.
class MealController extends ChangeNotifier {
  MealController(
    this._dailyLog, {
    this._calculator = const NutritionCalculator(),
    this._uuid = const Uuid(),
  });

  DailyLogController _dailyLog;
  final NutritionCalculator _calculator;
  final Uuid _uuid;

  void updateDailyLog(DailyLogController dailyLog) => _dailyLog = dailyLog;

  int caloriesFromMacros({
    required double carbsG,
    required double proteinG,
    required double fatG,
  }) => _calculator
      .caloriesFromMacros(carbsG: carbsG, proteinG: proteinG, fatG: fatG)
      .round();

  /// Retorna erro se as calorias não baterem com os macros (±10%).
  ValidationError? validateCalories({
    required int calories,
    required double carbsG,
    required double proteinG,
    required double fatG,
  }) {
    final matches = _calculator.caloriesMatchMacros(
      calories: calories,
      carbsG: carbsG,
      proteinG: proteinG,
      fatG: fatG,
    );
    if (matches) return null;
    return CaloriesMismatchError(
      caloriesFromMacros(carbsG: carbsG, proteinG: proteinG, fatG: fatG),
    );
  }

  /// Refeições novas são sempre registradas no dia de hoje.
  Meal addMeal({
    required MealType type,
    required String description,
    required int calories,
    required double carbsG,
    required double proteinG,
    required double fatG,
  }) {
    final now = DateTime.now();
    final meal = Meal(
      id: _uuid.v4(),
      type: type,
      description: description.trim(),
      calories: calories,
      carbsG: carbsG,
      proteinG: proteinG,
      fatG: fatG,
      createdAt: now,
    );
    _dailyLog
      ..appendMealToDay(now, meal)
      ..selectDate(now);
    notifyListeners();
    return meal;
  }

  void updateMeal(Meal meal) {
    _dailyLog.replaceMeal(meal);
    notifyListeners();
  }

  void deleteMeal(Meal meal) {
    _dailyLog.removeMeal(meal);
    notifyListeners();
  }
}
