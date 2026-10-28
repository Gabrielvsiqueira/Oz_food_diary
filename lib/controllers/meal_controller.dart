import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/meal_type.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../repositories/meal_repository.dart';
import '../services/validators.dart';
import 'daily_log_controller.dart';

class MealController extends ChangeNotifier {
  MealController(this._repository, this._dailyLog, {this._uuid = const Uuid()});

  final MealRepository _repository;
  DailyLogController _dailyLog;
  final Uuid _uuid;

  void updateDailyLog(DailyLogController dailyLog) => _dailyLog = dailyLog;

  ValidationError? validateItems(List<MealItem> items) =>
      items.isEmpty ? const EmptyMealError() : null;

  Future<Meal> addMeal({
    required MealType type,
    required List<MealItem> items,
  }) async {
    final now = DateTime.now();
    final meal = Meal(id: _uuid.v4(), type: type, items: items, createdAt: now);
    await _repository.save(meal);
    _dailyLog.selectDate(now);
    notifyListeners();
    return meal;
  }

  Future<void> updateMeal(Meal meal) async {
    await _repository.save(meal);
    notifyListeners();
  }

  Future<void> deleteMeal(Meal meal) async {
    await _repository.delete(meal);
    notifyListeners();
  }
}
