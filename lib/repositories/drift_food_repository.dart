import 'package:drift/drift.dart';

import '../database/app_database.dart';
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
