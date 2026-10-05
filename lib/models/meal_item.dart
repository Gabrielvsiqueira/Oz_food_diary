import 'food.dart';
import 'food_portion.dart';

class MealItem {
  const MealItem({
    required this.food,
    required this.portion,
    required this.quantity,
  });

  final Food food;
  final FoodPortion portion;
  final double quantity;

  double get grams => quantity * portion.grams;

  double get calories => food.kcalPer100g * grams / 100;
  double get carbsG => food.carbsPer100g * grams / 100;
  double get proteinG => food.proteinPer100g * grams / 100;
  double get fatG => food.fatPer100g * grams / 100;

  MealItem copyWith({FoodPortion? portion, double? quantity}) => MealItem(
    food: food,
    portion: portion ?? this.portion,
    quantity: quantity ?? this.quantity,
  );
}
