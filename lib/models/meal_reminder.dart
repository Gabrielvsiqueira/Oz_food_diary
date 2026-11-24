import 'enums/meal_type.dart';

/// Lembrete diário de uma refeição, no horário local do aparelho.
class MealReminder {
  const MealReminder({
    required this.type,
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  /// Café 8h, almoço 12h30, lanche 16h (desligado) e jantar 19h30.
  static const defaults = [
    MealReminder(type: MealType.breakfast, enabled: true, hour: 8, minute: 0),
    MealReminder(type: MealType.lunch, enabled: true, hour: 12, minute: 30),
    MealReminder(type: MealType.snack, enabled: false, hour: 16, minute: 0),
    MealReminder(type: MealType.dinner, enabled: true, hour: 19, minute: 30),
  ];

  final MealType type;
  final bool enabled;
  final int hour;
  final int minute;

  MealReminder copyWith({bool? enabled, int? hour, int? minute}) =>
      MealReminder(
        type: type,
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}
