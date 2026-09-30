import '../models/daily_log.dart';
import '../models/enums/meal_type.dart';
import '../models/meal.dart';
import '../services/date_utils.dart';

List<DailyLog> buildMockDailyLogs({DateTime? now}) {
  final base = dateOnly(now ?? DateTime.now());
  final yesterday = base.subtract(const Duration(days: 1));
  final twoDaysAgo = base.subtract(const Duration(days: 2));

  DateTime at(DateTime day, int hour, int minute) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  return [
    DailyLog(
      date: yesterday,
      meals: [
        Meal(
          id: 'mock-1',
          type: MealType.breakfast,
          description: 'Pão, manteiga e café',
          carbsG: 25,
          proteinG: 5,
          fatG: 9,
          createdAt: at(yesterday, 8, 15),
        ),
        Meal(
          id: 'mock-2',
          type: MealType.lunch,
          description: 'Arroz, feijão, frango grelhado e salada',
          carbsG: 75,
          proteinG: 45,
          fatG: 18,
          createdAt: at(yesterday, 12, 30),
        ),
        Meal(
          id: 'mock-3',
          type: MealType.dinner,
          description: 'Omelete com queijo',
          carbsG: 4,
          proteinG: 26,
          fatG: 28,
          createdAt: at(yesterday, 20, 0),
        ),
      ],
    ),
    DailyLog(
      date: twoDaysAgo,
      meals: [
        Meal(
          id: 'mock-4',
          type: MealType.snack,
          description: 'Iogurte natural com banana',
          carbsG: 32,
          proteinG: 8,
          fatG: 4,
          createdAt: at(twoDaysAgo, 16, 0),
        ),
      ],
    ),
  ];
}
