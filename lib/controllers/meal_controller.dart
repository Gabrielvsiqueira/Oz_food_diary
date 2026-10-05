import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/meal_type.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../services/validators.dart';
import 'daily_log_controller.dart';

class MealController extends ChangeNotifier {
  MealController(this._dailyLog, {this._uuid = const Uuid()});

  DailyLogController _dailyLog;
  final Uuid _uuid;

  void updateDailyLog(DailyLogController dailyLog) => _dailyLog = dailyLog;

  ValidationError? validateItems(List<MealItem> items) =>
      items.isEmpty ? const EmptyMealError() : null;

  Meal addMeal({required MealType type, required List<MealItem> items}) {
    final now = DateTime.now();
    final meal = Meal(id: _uuid.v4(), type: type, items: items, createdAt: now);
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
