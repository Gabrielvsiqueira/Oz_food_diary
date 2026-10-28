import '../models/meal.dart';

abstract interface class MealRepository {
  /// Refeições do dia, atualizadas a cada gravação.
  Stream<List<Meal>> watchMealsOn(DateTime day);

  /// Cria ou atualiza a refeição e seus itens.
  Future<void> save(Meal meal);

  Future<void> delete(Meal meal);
}
