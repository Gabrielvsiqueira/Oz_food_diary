import 'food_portion.dart';

class Food {
  const Food({
    required this.id,
    required this.name,
    required this.emoji,
    required this.kcalPer100g,
    required this.carbsPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    this.householdPortions = const [],
  });

  final String id;
  final String name;
  final String emoji;
  final double kcalPer100g;
  final double carbsPer100g;
  final double proteinPer100g;
  final double fatPer100g;

  final List<FoodPortion> householdPortions;

  List<FoodPortion> get portions => [FoodPortion.gram, ...householdPortions];

  FoodPortion get defaultPortion =>
      householdPortions.isEmpty ? FoodPortion.gram : householdPortions.first;

  @override
  bool operator ==(Object other) => other is Food && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
