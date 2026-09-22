import 'enums/meal_type.dart';

class Meal {
  const Meal({
    required this.id,
    required this.type,
    required this.description,
    required this.calories,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.createdAt,
  });

  final String id;
  final MealType type;
  final String description;
  final int calories;
  final double carbsG;
  final double proteinG;
  final double fatG;
  final DateTime createdAt;

  Meal copyWith({
    MealType? type,
    String? description,
    int? calories,
    double? carbsG,
    double? proteinG,
    double? fatG,
  }) {
    return Meal(
      id: id,
      type: type ?? this.type,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      carbsG: carbsG ?? this.carbsG,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      createdAt: createdAt,
    );
  }
}
