import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/enums/meal_type.dart';
import '../models/meal_reminder.dart';
import '../repositories/meal_repository.dart';
import '../repositories/reminder_repository.dart';
import '../services/date_utils.dart';
import '../services/reminder_planner.dart';
import '../services/reminder_scheduler.dart';
import 'session_controller.dart';

/// Dono dos lembretes de refeição. Com a sessão aberta, mantém agendados os
/// próximos 7 dias e pula o lembrete de hoje de uma refeição já registrada.
/// Reagenda quando uma refeição de hoje é salva ou excluída, quando um
/// horário muda e quando o app volta para a tela. Sem sessão, não agenda.
class ReminderController extends ChangeNotifier {
  ReminderController({
    required this._session,
    required this._repository,
    required this._scheduler,
    required this._meals,
    this._now = DateTime.now,
  }) {
    _session.addListener(_onSession);
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    _onSession();
  }

  final SessionController _session;
  final ReminderRepository _repository;
  final ReminderScheduler _scheduler;
  final MealRepository _meals;
  final DateTime Function() _now;
  late final AppLifecycleListener _lifecycle;

  bool _active = false;
  List<MealReminder> _reminders = MealReminder.defaults;
  bool? _permissionGranted;
  Set<MealType> _loggedToday = const {};
  DateTime? _watchedDay;
  StreamSubscription<void>? _todayMeals;

  /// Agendamentos em fila: um termina antes do próximo começar.
  Future<void> _scheduling = Future.value();

  List<MealReminder> get reminders => _reminders;

  /// `null` enquanto não foi verificada.
  bool? get permissionGranted => _permissionGranted;

  void _onSession() {
    final authenticated = _session.isAuthenticated;
    if (authenticated && !_active) unawaited(_start());
    if (!authenticated && _active) unawaited(_stop());
  }

  Future<void> _start() async {
    _active = true;
    _reminders = await _repository.load();
    _permissionGranted = await _scheduler.hasPermission();
    if (!_active) return;
    _watchToday();
    notifyListeners();
  }

  /// Logout: nada de lembretes para quem saiu da conta.
  Future<void> _stop() async {
    _active = false;
    await _todayMeals?.cancel();
    _todayMeals = null;
    _watchedDay = null;
    _reminders = MealReminder.defaults;
    _loggedToday = const {};
    await _enqueue(_scheduler.cancelAll);
    notifyListeners();
  }

  /// As refeições de hoje decidem quais lembretes de hoje pular.
  void _watchToday() {
    final day = dateOnly(_now());
    _watchedDay = day;
    unawaited(_todayMeals?.cancel());
    _todayMeals = _meals.watchMealsOn(day).listen((meals) {
      _loggedToday = {for (final meal in meals) meal.type};
      unawaited(_reschedule());
    });
  }

  Future<void> _onResume() async {
    if (!_active) return;
    // A permissão pode ter sido liberada nos ajustes do aparelho.
    _permissionGranted = await _scheduler.hasPermission();
    notifyListeners();
    if (!isSameDay(_watchedDay ?? _now(), _now())) {
      // Novo dia: as refeições de "hoje" são outras.
      _loggedToday = const {};
      _watchToday();
    } else {
      // A janela de 7 dias anda junto com o tempo.
      await _reschedule();
    }
  }

  Future<void> setEnabled(MealType type, {required bool enabled}) async {
    await _update(type, (r) => r.copyWith(enabled: enabled));
    if (enabled && _permissionGranted != true) await requestPermission();
  }

  Future<void> setTime(
    MealType type, {
    required int hour,
    required int minute,
  }) => _update(type, (r) => r.copyWith(hour: hour, minute: minute));

  /// Pede a permissão do sistema; `true` se ficou liberada.
  Future<bool> requestPermission() async {
    final granted = await _scheduler.requestPermission();
    _permissionGranted = granted;
    notifyListeners();
    return granted;
  }

  Future<void> _update(
    MealType type,
    MealReminder Function(MealReminder) change,
  ) async {
    final updated = change(_reminders.firstWhere((r) => r.type == type));
    _reminders = [
      for (final r in _reminders)
        if (r.type == type) updated else r,
    ];
    notifyListeners();
    await _repository.save(updated);
    await _reschedule();
  }

  Future<void> _reschedule() => _enqueue(() async {
    if (!_active) return;
    await _scheduler.replaceAll(
      planReminders(
        reminders: _reminders,
        now: _now(),
        loggedToday: _loggedToday,
      ),
    );
  });

  Future<void> _enqueue(Future<void> Function() task) {
    final next = _scheduling.then((_) => task()).catchError((Object e) {
      debugPrint('Falha ao agendar lembretes: $e');
    });
    _scheduling = next;
    return next;
  }

  @override
  void dispose() {
    _session.removeListener(_onSession);
    _lifecycle.dispose();
    _todayMeals?.cancel();
    super.dispose();
  }
}
