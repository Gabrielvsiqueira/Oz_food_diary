import '../models/daily_log.dart';
import '../models/enums/meal_type.dart';
import '../models/food.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../services/date_utils.dart';
import 'mock_foods.dart';

List<DailyLog> buildMockDailyLogs({DateTime? now}) {
  final base = dateOnly(now ?? DateTime.now());
  final yesterday = base.subtract(const Duration(days: 1));
  final twoDaysAgo = base.subtract(const Duration(days: 2));

  DateTime at(DateTime day, int hour, int minute) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  MealItem portions(Food food, double quantity) =>
      MealItem(food: food, portion: food.defaultPortion, quantity: quantity);

  return [
    DailyLog(
      date: yesterday,
      meals: [
        Meal(
          id: 'mock-1',
          type: MealType.breakfast,
          items: [
            portions(MockFoods.frenchBread, 1),
            portions(MockFoods.butter, 1),
            portions(MockFoods.coffee, 1),
          ],
          createdAt: at(yesterday, 8, 15),
        ),
        Meal(
          id: 'mock-2',
          type: MealType.lunch,
          items: [
            portions(MockFoods.whiteRice, 4),
            portions(MockFoods.pintoBeans, 1),
            portions(MockFoods.chickenBreast, 1),
            portions(MockFoods.tomato, 1),
          ],
          createdAt: at(yesterday, 12, 30),
        ),
        Meal(
          id: 'mock-3',
          type: MealType.dinner,
          items: [
            portions(MockFoods.egg, 3),
            portions(MockFoods.mozzarella, 1),
            portions(MockFoods.oliveOil, 0.5),
          ],
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
          items: [portions(MockFoods.yogurt, 1), portions(MockFoods.banana, 1)],
          createdAt: at(twoDaysAgo, 16, 0),
        ),
      ],
    ),
  ];
}
