/// Falhas ao buscar um produto na base externa (Open Food Facts). A
/// mensagem exibida fica na camada de View (`string_extensions.dart`).
sealed class ProductLookupFailure implements Exception {
  const ProductLookupFailure();
}

/// Sem internet ou servidor fora do ar: dá para tentar de novo depois.
class ProductLookupOfflineFailure extends ProductLookupFailure {
  const ProductLookupOfflineFailure();
}

/// O servidor respondeu com erro ou com algo que não dá para ler.
class ProductLookupServerFailure extends ProductLookupFailure {
  const ProductLookupServerFailure([this.cause]);
  final Object? cause;

  @override
  String toString() => 'ProductLookupServerFailure($cause)';
}
