import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/ids.dart';
import '../models/food.dart';
import '../models/food_portion.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../services/date_utils.dart';
import 'drift_food_repository.dart';
import 'meal_repository.dart';

class DriftMealRepository implements MealRepository {
  const DriftMealRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Meal>> watchMealsOn(DateTime day) {
    final meals = _db.meals;
    final items = _db.mealItems;
    final query =
        _db.select(meals).join([
            leftOuterJoin(
              items,
              items.mealId.equalsExp(meals.id) & items.deletedAt.isNull(),
            ),
          ])
          ..where(meals.localDate.equalsValue(day) & meals.deletedAt.isNull())
          ..orderBy([
            OrderingTerm.asc(meals.eatenAt),
            OrderingTerm.asc(items.position),
          ]);
    return query.watch().asyncMap((rows) async {
      final mealRows = <String, MealRow>{};
      final itemRows = <String, List<MealItemRow>>{};
      for (final row in rows) {
        final meal = row.readTable(meals);
        mealRows[meal.id] = meal;
        final item = row.readTableOrNull(items);
        if (item != null) (itemRows[meal.id] ??= []).add(item);
      }
      final portions = await portionsFor(
        _db,
        itemRows.values.expand((i) => i).map((i) => i.foodId).nonNulls,
      );
      return [
        for (final meal in mealRows.values)
          Meal(
            id: meal.id,
            type: meal.type,
            createdAt: meal.eatenAt.toLocal(),
            items: [
              for (final item in itemRows[meal.id] ?? const <MealItemRow>[])
                _toMealItem(item, portions[item.foodId] ?? const []),
            ],
          ),
      ];
    });
  }

  @override
  Future<void> save(Meal meal) => _db.transaction(() async {
    final now = DateTime.now().toUtc();
    await _db
        .into(_db.meals)
        .insert(
          MealsCompanion.insert(
            id: meal.id,
            type: meal.type,
            eatenAt: meal.createdAt,
            localDate: dateOnly(meal.createdAt),
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => MealsCompanion(
              type: Value(meal.type),
              updatedAt: Value(now),
              deletedAt: const Value(null),
              isDirty: const Value(true),
            ),
          ),
        );

    for (final (position, item) in meal.items.indexed) {
      final row = MealItemsCompanion.insert(
        id: mealItemId(meal.id, position),
        mealId: meal.id,
        foodId: Value(item.food.id),
        position: position,
        foodName: item.food.name,
        foodEmoji: item.food.emoji,
        kcal100g: item.food.kcalPer100g,
        carbs100g: item.food.carbsPer100g,
        protein100g: item.food.proteinPer100g,
        fat100g: item.food.fatPer100g,
        portionUnit: item.portion.unit,
        portionGrams: item.portion.grams,
        quantity: item.quantity,
        createdAt: now,
        updatedAt: now,
      );
      await _db
          .into(_db.mealItems)
          .insert(
            row,
            onConflict: DoUpdate(
              (_) => row.copyWith(
                createdAt: const Value.absent(),
                deletedAt: const Value(null),
                isDirty: const Value(true),
              ),
            ),
          );
    }

    // Itens que sobraram de uma versão maior da refeição.
    await (_db.update(_db.mealItems)..where(
          (i) =>
              i.mealId.equals(meal.id) &
              i.position.isBiggerOrEqualValue(meal.items.length) &
              i.deletedAt.isNull(),
        ))
        .write(_tombstone(now));
  });

  @override
  Future<void> delete(Meal meal) => _db.transaction(() async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.meals)..where((m) => m.id.equals(meal.id))).write(
      MealsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
    await (_db.update(_db.mealItems)..where(
          (i) => i.mealId.equals(meal.id) & i.deletedAt.isNull(),
        ))
        .write(_tombstone(now));
  });

  MealItemsCompanion _tombstone(DateTime now) => MealItemsCompanion(
    deletedAt: Value(now),
    updatedAt: Value(now),
    isDirty: const Value(true),
  );

  /// Monta o item a partir da cópia guardada. As medidas caseiras vêm do
  /// catálogo atual, garantindo que a medida usada no item continue na lista.
  MealItem _toMealItem(MealItemRow row, List<FoodPortion> catalogPortions) {
    final portion = FoodPortion(row.portionUnit, row.portionGrams);
    return MealItem(
      food: Food(
        id: row.foodId ?? row.id,
        name: row.foodName,
        emoji: row.foodEmoji,
        kcalPer100g: row.kcal100g,
        carbsPer100g: row.carbs100g,
        proteinPer100g: row.protein100g,
        fatPer100g: row.fat100g,
        householdPortions: [
          ...catalogPortions,
          if (portion != FoodPortion.gram && !catalogPortions.contains(portion))
            portion,
        ],
      ),
      portion: portion,
      quantity: row.quantity,
    );
  }
}
