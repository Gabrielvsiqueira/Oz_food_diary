import '../models/meal_reminder.dart';

abstract interface class ReminderRepository {
  /// Um lembrete por tipo de refeição, com o padrão onde nada foi salvo.
  Future<List<MealReminder>> load();

  Future<void> save(MealReminder reminder);
}
