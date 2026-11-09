import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/enums/food_source.dart';
import '../models/food.dart';
import '../models/food_portion.dart';
import '../services/text_utils.dart';
import 'food_repository.dart';

class DriftFoodRepository implements FoodRepository {
  const DriftFoodRepository(this._db, {this.limit = 100});

  final AppDatabase _db;
  final int limit;

  @override
  Future<List<Food>> search(String query) async {
    final terms = normalizeForSearch(
      query,
    ).split(' ').where((t) => t.isNotEmpty).map(_escapeLike);
    final rows =
        await (_db.select(_db.foods)
              ..where(
                (f) => Expression.and([
                  for (final term in terms)
                    f.searchName.like('%$term%', escapeChar: r'\'),
                ]),
              )
              ..orderBy([(f) => OrderingTerm.asc(f.searchName)])
              ..limit(limit))
            .get();
    return _toFoods(rows);
  }

  @override
  Future<Food?> findByBarcode(String barcode) async {
    final row = await (_db.select(
      _db.foods,
    )..where((f) => f.barcode.equals(barcode))).getSingleOrNull();
    if (row == null) return null;
    return (await _toFoods([row])).single;
  }

  @override
  Future<void> saveProduct(
    Food food, {
    required String barcode,
    required FoodSource source,
  }) => _db.transaction(() async {
    await _db
        .into(_db.foods)
        .insertOnConflictUpdate(
          FoodsCompanion.insert(
            id: food.id,
            source: source,
            sourceRef: Value(source == FoodSource.off ? barcode : null),
            barcode: Value(barcode),
            name: food.name,
            searchName: normalizeForSearch(food.name),
            emoji: food.emoji,
            kcal100g: food.kcalPer100g,
            carbs100g: food.carbsPer100g,
            protein100g: food.proteinPer100g,
            fat100g: food.fatPer100g,
          ),
        );
    await (_db.delete(
      _db.foodPortions,
    )..where((p) => p.foodId.equals(food.id))).go();
    await _db.batch(
      (batch) => batch.insertAll(_db.foodPortions, [
        for (final (index, portion) in food.householdPortions.indexed)
          FoodPortionsCompanion.insert(
            foodId: food.id,
            unit: portion.unit,
            grams: portion.grams,
            position: index,
          ),
      ]),
    );
  });

  Future<List<Food>> _toFoods(List<FoodRow> rows) async {
    final portions = await portionsFor(_db, rows.map((r) => r.id));
    return [
      for (final row in rows)
        Food(
          id: row.id,
          name: row.name,
          emoji: row.emoji,
          kcalPer100g: row.kcal100g,
          carbsPer100g: row.carbs100g,
          proteinPer100g: row.protein100g,
          fatPer100g: row.fat100g,
          householdPortions: portions[row.id] ?? const [],
        ),
    ];
  }
}

/// Medidas caseiras de cada alimento, na ordem de exibição.
Future<Map<String, List<FoodPortion>>> portionsFor(
  AppDatabase db,
  Iterable<String> foodIds,
) async {
  final ids = foodIds.toSet();
  if (ids.isEmpty) return const {};
  final rows =
      await (db.select(db.foodPortions)
            ..where((p) => p.foodId.isIn(ids))
            ..orderBy([(p) => OrderingTerm.asc(p.position)]))
          .get();
  final result = <String, List<FoodPortion>>{};
  for (final row in rows) {
    (result[row.foodId] ??= []).add(FoodPortion(row.unit, row.grams));
  }
  return result;
}

String _escapeLike(String term) =>
    term.replaceAllMapped(RegExp(r'[%_\\]'), (m) => '\\${m[0]}');
