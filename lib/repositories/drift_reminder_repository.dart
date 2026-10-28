import '../database/app_database.dart';
import '../models/meal_reminder.dart';
import 'reminder_repository.dart';

class DriftReminderRepository implements ReminderRepository {
  const DriftReminderRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<MealReminder>> load() async {
    final rows = {
      for (final row in await _db.select(_db.reminderSettings).get())
        row.mealType: row,
    };
    return [
      for (final reminder in MealReminder.defaults)
        if (rows[reminder.type] case final row?)
          reminder.copyWith(
            enabled: row.enabled,
            hour: row.minuteOfDay ~/ 60,
            minute: row.minuteOfDay % 60,
          )
        else
          reminder,
    ];
  }

  @override
  Future<void> save(MealReminder reminder) => _db
      .into(_db.reminderSettings)
      .insertOnConflictUpdate(
        ReminderSettingsCompanion.insert(
          mealType: reminder.type,
          enabled: reminder.enabled,
          minuteOfDay: reminder.hour * 60 + reminder.minute,
        ),
      );
}
