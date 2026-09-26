import 'package:flutter/foundation.dart';

import '../mocks/mock_daily_logs.dart';
import '../models/daily_log.dart';
import '../models/meal.dart';
import '../services/date_utils.dart';

/// Dia selecionado na Home e refeições agrupadas por dia.
/// Nunca permite selecionar uma data depois de hoje.
class DailyLogController extends ChangeNotifier {
  DailyLogController() {
    _seed();
  }

  final Map<DateTime, DailyLog> _logs = {};
  late DateTime _selectedDate;

  DateTime get selectedDate => _selectedDate;

  DailyLog get selectedLog => logFor(_selectedDate);

  bool get isTodaySelected => isSameDay(_selectedDate, today());

  bool get canGoToNextDay => _selectedDate.isBefore(today());

  DailyLog logFor(DateTime date) {
    final day = dateOnly(date);
    return _logs[day] ?? DailyLog(date: day);
  }

  void _seed() {
    _logs.clear();
    for (final log in buildMockDailyLogs()) {
      _logs[log.date] = log;
    }
    _selectedDate = today();
  }

  void selectDate(DateTime date) {
    final day = dateOnly(date);
    final now = today();
    _selectedDate = day.isAfter(now) ? now : day;
    notifyListeners();
  }

  void goToPreviousDay() =>
      selectDate(_selectedDate.subtract(const Duration(days: 1)));

  void goToNextDay() {
    if (!canGoToNextDay) return;
    selectDate(_selectedDate.add(const Duration(days: 1)));
  }

  void appendMealToDay(DateTime date, Meal meal) {
    final log = logFor(date);
    _logs[log.date] = log.copyWith(meals: [...log.meals, meal]);
    notifyListeners();
  }

  void replaceMeal(Meal meal) {
    final log = logFor(meal.createdAt);
    _logs[log.date] = log.copyWith(
      meals: [for (final m in log.meals) m.id == meal.id ? meal : m],
    );
    notifyListeners();
  }

  void removeMeal(Meal meal) {
    final log = logFor(meal.createdAt);
    _logs[log.date] = log.copyWith(
      meals: log.meals.where((m) => m.id != meal.id).toList(),
    );
    notifyListeners();
  }

  void reset() {
    _seed();
    notifyListeners();
  }
}
