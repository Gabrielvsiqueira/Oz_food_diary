import '../models/food.dart';

abstract interface class FoodRepository {
  Future<List<Food>> search(String query);
}
