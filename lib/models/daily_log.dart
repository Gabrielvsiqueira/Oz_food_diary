import 'meal.dart';

class DailyLog {
  DailyLog({required this.date, List<Meal> meals = const []})
    : meals = List.unmodifiable(
        [...meals]..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      );

  final DateTime date;
  final List<Meal> meals;

  int get totalCalories => meals.fold(0, (sum, m) => sum + m.calories);
  double get totalCarbsG => meals.fold(0, (sum, m) => sum + m.carbsG);
  double get totalProteinG => meals.fold(0, (sum, m) => sum + m.proteinG);
  double get totalFatG => meals.fold(0, (sum, m) => sum + m.fatG);

  DailyLog copyWith({List<Meal>? meals}) =>
      DailyLog(date: date, meals: meals ?? this.meals);
}
