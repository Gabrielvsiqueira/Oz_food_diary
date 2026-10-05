import '../mocks/mock_foods.dart';
import '../models/food.dart';
import '../services/text_utils.dart';
import 'food_repository.dart';

/// Implementação em memória, com latência simulada para exercitar os
/// estados de carregamento da UI como numa chamada de rede.
class MockFoodRepository implements FoodRepository {
  const MockFoodRepository({
    this.foods = MockFoods.all,
    this.latency = const Duration(milliseconds: 400),
  });

  final List<Food> foods;
  final Duration latency;

  @override
  Future<List<Food>> search(String query) async {
    await Future<void>.delayed(latency);
    final terms = normalizeForSearch(
      query,
    ).split(' ').where((t) => t.isNotEmpty);
    return foods.where((food) {
      final name = normalizeForSearch(food.name);
      return terms.every(name.contains);
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }
}
