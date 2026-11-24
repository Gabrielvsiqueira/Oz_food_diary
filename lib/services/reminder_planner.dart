import '../models/enums/meal_type.dart';
import '../models/meal_reminder.dart';

/// Um lembrete agendado: [id] é fixo por dia e refeição.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.type,
    required this.when,
  });

  final int id;
  final MealType type;
  final DateTime when;
}

/// Lembretes dos próximos [days] dias, um a um (e não um alarme diário
/// repetido), para poder pular o de hoje de uma refeição já registrada.
/// 4 refeições × 7 dias = 28, abaixo do limite de 64 do iOS.
List<PlannedReminder> planReminders({
  required List<MealReminder> reminders,
  required DateTime now,
  required Set<MealType> loggedToday,
  int days = 7,
}) {
  final planned = <PlannedReminder>[];
  for (var day = 0; day < days; day++) {
    for (final reminder in reminders) {
      if (!reminder.enabled) continue;
      if (day == 0 && loggedToday.contains(reminder.type)) continue;
      final at = DateTime(
        now.year,
        now.month,
        now.day + day,
        reminder.hour,
        reminder.minute,
      );
      if (!at.isAfter(now)) continue;
      planned.add(
        PlannedReminder(
          id: day * 10 + reminder.type.index,
          type: reminder.type,
          when: at,
        ),
      );
    }
  }
  return planned;
}
