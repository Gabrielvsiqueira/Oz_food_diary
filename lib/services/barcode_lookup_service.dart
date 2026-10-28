import '../models/enums/food_source.dart';
import '../models/food.dart';
import '../models/product_info.dart';
import '../repositories/food_repository.dart';
import '../repositories/product_repository.dart';

sealed class BarcodeLookupResult {
  const BarcodeLookupResult();
}

/// Pronto para usar: já estava no aparelho ou veio completo da internet.
class BarcodeFoodFound extends BarcodeLookupResult {
  const BarcodeFoodFound(this.food);
  final Food food;
}

/// A base externa conhece o produto, mas faltam nome ou nutrientes.
class BarcodeProductIncomplete extends BarcodeLookupResult {
  const BarcodeProductIncomplete(this.product);
  final ProductInfo product;
}

class BarcodeProductNotFound extends BarcodeLookupResult {
  const BarcodeProductNotFound(this.barcode);
  final String barcode;
}

/// Procura primeiro no aparelho (funciona offline) e depois na base externa.
/// O que vem de fora fica salvo: a próxima leitura não usa a internet.
class BarcodeLookupService {
  const BarcodeLookupService(this._foods, this._products);

  final FoodRepository _foods;
  final ProductRepository _products;

  /// Lança `ProductLookupFailure` quando precisa da internet e não consegue.
  Future<BarcodeLookupResult> lookup(String barcode) async {
    final saved = await _foods.findByBarcode(barcode);
    if (saved != null) return BarcodeFoodFound(saved);

    final product = await _products.findByBarcode(barcode);
    if (product == null) return BarcodeProductNotFound(barcode);
    if (!product.isComplete) return BarcodeProductIncomplete(product);
    return BarcodeFoodFound(await save(product, source: FoodSource.off));
  }

  /// Salva um produto completado ou cadastrado pelo usuário.
  Future<Food> save(ProductInfo product, {required FoodSource source}) async {
    final food = product.toFood(id: '${source.name}-${product.barcode}');
    await _foods.saveProduct(food, barcode: product.barcode, source: source);
    return food;
  }
}
