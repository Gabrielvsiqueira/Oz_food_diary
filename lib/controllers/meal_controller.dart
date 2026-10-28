import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/meal_type.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../repositories/meal_repository.dart';
import '../services/date_utils.dart';
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
    String? photoPath,
  }) async {
    final meal = Meal(
      id: _uuid.v4(),
      type: type,
      items: items,
      createdAt: _eatenAtOnSelectedDay(),
      photoPath: photoPath,
    );
    await _repository.save(meal);
    notifyListeners();
    return meal;
  }

  /// A refeição nova vai para o dia aberto na Home (para registrar algo
  /// esquecido ontem), no horário de agora.
  DateTime _eatenAtOnSelectedDay() {
    final now = DateTime.now();
    final day = _dailyLog.selectedDate;
    if (isSameDay(day, now)) return now;
    return DateTime(day.year, day.month, day.day, now.hour, now.minute);
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
