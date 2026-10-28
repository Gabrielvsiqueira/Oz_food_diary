import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/enums/activity_level.dart';
import '../models/enums/food_source.dart';
import '../models/enums/gender.dart';
import '../models/enums/goal_type.dart';
import '../models/enums/meal_type.dart';
import '../models/enums/portion_unit.dart';
import '../models/food.dart';
import '../services/text_utils.dart';
import 'date_only_converter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    NutritionGoals,
    WeightEntries,
    Meals,
    MealItems,
    Foods,
    FoodPortions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor, {this.foodSeed});

  AppDatabase.open({Future<List<Food>> Function()? foodSeed})
    : this(driftDatabase(name: 'oz'), foodSeed: foodSeed);

  /// Catálogo inicial, inserido só quando o banco é criado.
  final Future<List<Food>> Function()? foodSeed;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated && foodSeed != null) {
        await insertFoods(await foodSeed!());
      }
    },
  );

  Future<void> insertFoods(
    List<Food> catalog, {
    FoodSource source = FoodSource.taco,
  }) => batch((batch) {
    batch.insertAllOnConflictUpdate(foods, [
      for (final food in catalog)
        FoodsCompanion.insert(
          id: food.id,
          source: source,
          name: food.name,
          searchName: normalizeForSearch(food.name),
          emoji: food.emoji,
          kcal100g: food.kcalPer100g,
          carbs100g: food.carbsPer100g,
          protein100g: food.proteinPer100g,
          fat100g: food.fatPer100g,
        ),
    ]);
    batch.insertAllOnConflictUpdate(foodPortions, [
      for (final food in catalog)
        for (final (index, portion) in food.householdPortions.indexed)
          FoodPortionsCompanion.insert(
            foodId: food.id,
            unit: portion.unit,
            grams: portion.grams,
            position: index,
          ),
    ]);
  });

  /// Apaga os dados do usuário deste aparelho (logout). O catálogo de
  /// alimentos fica, pois é igual para todos.
  Future<void> clearUserData() => transaction(() async {
    await delete(mealItems).go();
    await delete(meals).go();
    await delete(weightEntries).go();
    await delete(nutritionGoals).go();
    await delete(profiles).go();
  });
}
