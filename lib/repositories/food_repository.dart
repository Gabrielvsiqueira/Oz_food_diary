import '../models/food.dart';

/// Fonte dos alimentos. A UI e os controllers dependem só desta interface,
/// então trocar os dados de exemplo por uma API (TACO, Open Food Facts ou
/// backend próprio) não exige mudanças fora desta camada.
abstract interface class FoodRepository {
  /// Alimentos cujo nome contém todas as palavras de [query], ignorando
  /// acentos e maiúsculas. Com [query] vazia, retorna todos.
  Future<List<Food>> search(String query);
}
