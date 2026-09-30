import '../services/nutrition_calculator.dart';
import 'enums/meal_type.dart';

class Meal {
  const Meal({
    required this.id,
    required this.type,
    required this.description,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.createdAt,
  });

  final String id;
  final MealType type;
  final String description;
  final double carbsG;
  final double proteinG;
  final double fatG;
  final DateTime createdAt;

  int get calories => const NutritionCalculator()
      .caloriesFromMacros(carbsG: carbsG, proteinG: proteinG, fatG: fatG)
      .round();

  Meal copyWith({
    MealType? type,
    String? description,
    double? carbsG,
    double? proteinG,
    double? fatG,
  }) {
    return Meal(
      id: id,
      type: type ?? this.type,
      description: description ?? this.description,
      carbsG: carbsG ?? this.carbsG,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      createdAt: createdAt,
    );
  }
}
