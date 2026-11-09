import 'enums/portion_unit.dart';
import 'food.dart';
import 'food_portion.dart';

/// Produto encontrado pelo código de barras, com valores a cada 100 g.
/// Campos `null` são os que a fonte não informou.
class ProductInfo {
  const ProductInfo({
    required this.barcode,
    this.name,
    this.kcalPer100g,
    this.carbsPer100g,
    this.proteinPer100g,
    this.fatPer100g,
    this.servingGrams,
  });

  static const emoji = '🛒';

  final String barcode;
  final String? name;
  final double? kcalPer100g;
  final double? carbsPer100g;
  final double? proteinPer100g;
  final double? fatPer100g;

  /// Porção da embalagem (ex.: "1 barra = 25 g").
  final double? servingGrams;

  bool get isComplete =>
      (name?.trim().isNotEmpty ?? false) &&
      kcalPer100g != null &&
      carbsPer100g != null &&
      proteinPer100g != null &&
      fatPer100g != null;

  /// Nada além do código: produto que a fonte não conhece.
  bool get isEmpty =>
      name == null &&
      kcalPer100g == null &&
      carbsPer100g == null &&
      proteinPer100g == null &&
      fatPer100g == null;

  /// Só para produtos completos ([isComplete]).
  Food toFood({required String id}) => Food(
    id: id,
    name: name!.trim(),
    emoji: emoji,
    kcalPer100g: kcalPer100g!,
    carbsPer100g: carbsPer100g!,
    proteinPer100g: proteinPer100g!,
    fatPer100g: fatPer100g!,
    householdPortions: [
      if (servingGrams != null) FoodPortion(PortionUnit.serving, servingGrams!),
    ],
  );
}
