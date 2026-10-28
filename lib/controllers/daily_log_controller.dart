import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/daily_log.dart';
import '../repositories/meal_repository.dart';
import '../services/date_utils.dart';

class DailyLogController extends ChangeNotifier {
  DailyLogController(this._repository, {this._today = today}) {
    _watch(_today());
  }

  final MealRepository _repository;
  final DateTime Function() _today;
  StreamSubscription<void>? _subscription;

  late DateTime _selectedDate;
  late DailyLog _selectedLog;

  /// O dia aberto era "hoje" quando foi escolhido: se a data virar com o app
  /// aberto, a Home deve acompanhar o novo dia.
  bool _followsToday = true;

  DateTime get selectedDate => _selectedDate;

  /// Dia em que uma refeição nova deve entrar: o aberto na Home, ou hoje se
  /// a Home estava em "hoje" e a data virou desde então.
  DateTime get dayForNewMeal => _followsToday ? _today() : _selectedDate;

  DailyLog get selectedLog => _selectedLog;

  bool get isTodaySelected => isSameDay(_selectedDate, _today());

  bool get canGoToNextDay => _selectedDate.isBefore(_today());

  /// Passa a acompanhar as refeições do dia: qualquer gravação no banco
  /// (formulário ou, no futuro, sincronização) atualiza a Home.
  void _watch(DateTime day) {
    _subscription?.cancel();
    _selectedDate = day;
    _followsToday = isSameDay(day, _today());
    _selectedLog = DailyLog(date: day);
    _subscription = _repository.watchMealsOn(day).listen((meals) {
      _selectedLog = DailyLog(date: day, meals: meals);
      notifyListeners();
    });
  }

  /// Se a Home estava em "hoje" e a data virou com o app em segundo plano,
  /// passa para o novo dia. Chamado quando o app volta para a tela.
  void followToday() {
    if (!_followsToday || isSameDay(_selectedDate, _today())) return;
    _watch(_today());
    notifyListeners();
  }

  void selectDate(DateTime date) {
    final day = dateOnly(date);
    final now = _today();
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
