import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/daily_log.dart';
import '../repositories/meal_repository.dart';
import '../services/date_utils.dart';

class DailyLogController extends ChangeNotifier {
  DailyLogController(this._repository) {
    _watch(today());
  }

  final MealRepository _repository;
  StreamSubscription<void>? _subscription;

  late DateTime _selectedDate;
  late DailyLog _selectedLog;

  DateTime get selectedDate => _selectedDate;

  DailyLog get selectedLog => _selectedLog;

  bool get isTodaySelected => isSameDay(_selectedDate, today());

  bool get canGoToNextDay => _selectedDate.isBefore(today());

  /// Passa a acompanhar as refeições do dia: qualquer gravação no banco
  /// (formulário ou, no futuro, sincronização) atualiza a Home.
  void _watch(DateTime day) {
    _subscription?.cancel();
    _selectedDate = day;
    _selectedLog = DailyLog(date: day);
    _subscription = _repository.watchMealsOn(day).listen((meals) {
      _selectedLog = DailyLog(date: day, meals: meals);
      notifyListeners();
    });
  }

  void selectDate(DateTime date) {
    final day = dateOnly(date);
    final now = today();
    final target = day.isAfter(now) ? now : day;
    if (!isSameDay(target, _selectedDate)) _watch(target);
    notifyListeners();
  }

  void goToPreviousDay() =>
      selectDate(_selectedDate.subtract(const Duration(days: 1)));

  void goToNextDay() {
    if (!canGoToNextDay) return;
    selectDate(_selectedDate.add(const Duration(days: 1)));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
