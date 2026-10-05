import 'enums/portion_unit.dart';

class FoodPortion {
  const FoodPortion(this.unit, this.grams);

  static const gram = FoodPortion(PortionUnit.gram, 1);

  final PortionUnit unit;
  final double grams;

  @override
  bool operator ==(Object other) =>
      other is FoodPortion && other.unit == unit && other.grams == grams;

  @override
  int get hashCode => Object.hash(unit, grams);
}
