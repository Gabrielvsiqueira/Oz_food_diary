import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/meal_type.dart';
import '../models/meal.dart';
import '../services/nutrition_calculator.dart';
import '../services/validators.dart';
import 'daily_log_controller.dart';

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

  ValidationError? validateMacros({
    required double carbsG,
    required double proteinG,
    required double fatG,
  }) => caloriesFromMacros(carbsG: carbsG, proteinG: proteinG, fatG: fatG) > 0
      ? null
      : const EmptyMacrosError();

  Meal addMeal({
    required MealType type,
    required String description,
    required double carbsG,
    required double proteinG,
    required double fatG,
  }) {
    final now = DateTime.now();
    final meal = Meal(
      id: _uuid.v4(),
      type: type,
      description: description.trim(),
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
