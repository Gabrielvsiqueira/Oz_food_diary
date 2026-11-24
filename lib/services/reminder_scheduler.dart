import 'reminder_planner.dart';

/// Agenda as notificações no aparelho (sem servidor: funciona offline).
abstract interface class ReminderScheduler {
  Future<bool> hasPermission();

  /// Pede a permissão de notificações (Android 13+ e iOS); `true` se ficou
  /// liberada.
  Future<bool> requestPermission();

  /// Troca tudo o que estava agendado por [reminders].
  Future<void> replaceAll(List<PlannedReminder> reminders);

  Future<void> cancelAll();
}
