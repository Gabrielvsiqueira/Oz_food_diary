import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../configs/constants/nutrition_constants.dart';
import '../models/product_info.dart';
import '../models/product_lookup_failure.dart';
import '../services/text_utils.dart';
import 'product_repository.dart';

/// Busca produtos na API pública da Open Food Facts (sem chave).
/// Dados sob a licença ODbL: o crédito aparece na busca de alimentos.
class OpenFoodFactsRepository implements ProductRepository {
  OpenFoodFactsRepository({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  /// A Open Food Facts pede um User-Agent que identifique o app.
  static const userAgent =
      'Oz/1.0.0 (https://github.com/Gabrielvsiqueira/Oz_food_diary)';

  static const _fields =
      'product_name,product_name_pt,generic_name,brands,serving_quantity,'
      'nutriments';

  final http.Client _client;
  final Duration timeout;

  void close() => _client.close();

  @override
  Future<ProductInfo?> findByBarcode(String barcode) async {
    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/$barcode',
      {'fields': _fields, 'lc': 'pt'},
    );
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'User-Agent': userAgent})
          .timeout(timeout);
    } on IOException {
      // Inclui SocketException e erros de TLS (ex.: Wi-Fi com portal de
      // login), que o http não converte em ClientException.
      throw const ProductLookupOfflineFailure();
    } on http.ClientException {
      throw const ProductLookupOfflineFailure();
    } on TimeoutException {
      throw const ProductLookupOfflineFailure();
    }

    // Produto inexistente volta como 404, com o mesmo corpo de "não achou".
    if (response.statusCode == HttpStatus.notFound) return null;
    if (response.statusCode != HttpStatus.ok) {
      throw ProductLookupServerFailure('HTTP ${response.statusCode}');
    }
    final Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException catch (e) {
      throw ProductLookupServerFailure(e);
    }
    if (body is! Map<String, Object?> || body['status'] != 1) return null;
    final product = body['product'];
    if (product is! Map<String, Object?>) return null;
    return parseProduct(barcode, product);
  }
}

/// Converte o JSON de um produto da Open Food Facts. Exposto para os testes.
ProductInfo parseProduct(String barcode, Map<String, Object?> product) {
  final nutriments = product['nutriments'];
  final values = nutriments is Map<String, Object?>
      ? nutriments
      : const <String, Object?>{};
  double? value(String key) => _number(values[key]);

  final serving = _number(product['serving_quantity']);
  return ProductInfo(
    barcode: barcode,
    name: _name(product),
    kcalPer100g: value('energy-kcal_100g') ?? _kjToKcal(value('energy_100g')),
    carbsPer100g: value('carbohydrates_100g'),
    proteinPer100g: value('proteins_100g'),
    fatPer100g: value('fat_100g'),
    servingGrams:
        serving != null &&
            serving > 0 &&
            serving <= NutritionConstants.maxFoodGrams
        ? serving
        : null,
  );
}

/// Nome em português quando houver, com a marca se ela não aparece no nome.
String? _name(Map<String, Object?> product) {
  String? text(String key) {
    final value = product[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  final name =
      text('product_name_pt') ?? text('product_name') ?? text('generic_name');
  final brand = text('brands')?.split(',').first.trim();
  if (name == null) return brand;
  if (brand == null ||
      brand.isEmpty ||
      normalizeForSearch(name).contains(normalizeForSearch(brand))) {
    return name;
  }
  return '$name · $brand';
}

/// `energy_100g` vem sempre em kJ.
double? _kjToKcal(double? kj) =>
    kj == null ? null : (kj / 4.184 * 10).roundToDouble() / 10;

/// Números chegam como número ou texto; negativos são tratados como
/// ausentes.
double? _number(Object? value) {
  final number = switch (value) {
    num() => value.toDouble(),
    String() => double.tryParse(value.trim().replaceAll(',', '.')),
    _ => null,
  };
  return number != null && number.isFinite && number >= 0 ? number : null;
}
