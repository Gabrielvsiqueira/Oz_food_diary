import 'dart:async';

import '../models/meal.dart';
import '../services/date_utils.dart';
import 'meal_repository.dart';

/// Implementação em memória, para testes.
class MockMealRepository implements MealRepository {
  MockMealRepository({List<Meal> meals = const []})
    : _meals = {for (final meal in meals) meal.id: meal};

  final Map<String, Meal> _meals;
  final _changes = StreamController<void>.broadcast();

  List<Meal> get meals => List.unmodifiable(_meals.values);

  @override
  Stream<List<Meal>> watchMealsOn(DateTime day) {
    StreamSubscription<void>? changes;
    late final StreamController<List<Meal>> controller;
    controller = StreamController(
      onListen: () {
        controller.add(_on(day));
        changes = _changes.stream.listen((_) => controller.add(_on(day)));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  List<Meal> _on(DateTime day) =>
      _meals.values.where((m) => isSameDay(m.createdAt, day)).toList();

  @override
  Future<void> save(Meal meal) async {
    _meals[meal.id] = meal;
    _changes.add(null);
  }

  @override
  Future<void> delete(Meal meal) async {
    _meals.remove(meal.id);
    _changes.add(null);
  }
}
