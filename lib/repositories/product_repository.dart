import '../models/product_info.dart';

/// Base externa de produtos industrializados, consultada pelo código de
/// barras.
abstract interface class ProductRepository {
  /// `null` quando o produto não existe na base. Lança
  /// `ProductLookupFailure` sem conexão ou com erro do servidor.
  Future<ProductInfo?> findByBarcode(String barcode);
}
