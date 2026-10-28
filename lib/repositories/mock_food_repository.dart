import '../mocks/mock_foods.dart';
import '../models/enums/food_source.dart';
import '../models/food.dart';
import '../services/text_utils.dart';
import 'food_repository.dart';

class MockFoodRepository implements FoodRepository {
  MockFoodRepository({
    List<Food> foods = MockFoods.all,
    this.latency = const Duration(milliseconds: 400),
  }) : foods = [...foods];

  final List<Food> foods;
  final Duration latency;
  final _barcodes = <String, Food>{};

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

  @override
  Future<Food?> findByBarcode(String barcode) async => _barcodes[barcode];

  @override
  Future<void> saveProduct(
    Food food, {
    required String barcode,
    required FoodSource source,
  }) async {
    foods
      ..remove(food)
      ..add(food);
    _barcodes[barcode] = food;
  }
}
