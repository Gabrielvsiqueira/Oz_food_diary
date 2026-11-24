import 'food_portion.dart';

class Food {
  const Food({
    required this.id,
    required this.name,
    required this.kcalPer100g,
    required this.carbsPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    this.householdPortions = const [],
    this.keywords = const [],
  });

  final String id;
  final String name;
  final double kcalPer100g;
  final double carbsPer100g;
  final double proteinPer100g;
  final double fatPer100g;

  final List<FoodPortion> householdPortions;

  /// Outros termos que encontram o alimento na busca, como preparos com os
  /// mesmos valores ("cozido") e nomes regionais ("pão francês").
  final List<String> keywords;

  List<FoodPortion> get portions => [FoodPortion.gram, ...householdPortions];

  FoodPortion get defaultPortion =>
      householdPortions.isEmpty ? FoodPortion.gram : householdPortions.first;

  @override
  bool operator ==(Object other) => other is Food && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
