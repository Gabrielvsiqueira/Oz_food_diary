import '../models/enums/food_source.dart';
import '../models/food.dart';

abstract interface class FoodRepository {
  Future<List<Food>> search(String query);

  /// Alimento já salvo no aparelho com esse código de barras.
  Future<Food?> findByBarcode(String barcode);

  /// Guarda um produto lido pelo código de barras; passa a aparecer na busca.
  Future<void> saveProduct(
    Food food, {
    required String barcode,
    required FoodSource source,
  });
}
