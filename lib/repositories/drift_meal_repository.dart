import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/ids.dart';
import '../models/food.dart';
import '../models/food_portion.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../services/date_utils.dart';
import '../services/meal_photo_storage.dart';
import 'drift_food_repository.dart';
import 'meal_repository.dart';

class DriftMealRepository implements MealRepository {
  /// Sem [photos], as fotos são ignoradas (testes que não usam arquivos).
  const DriftMealRepository(this._db, {this._photos});

  final AppDatabase _db;
  final MealPhotoStorage? _photos;

  @override
  Stream<List<Meal>> watchMealsOn(DateTime day) {
    final meals = _db.meals;
    final items = _db.mealItems;
    final photos = _db.mealPhotos;
    final query =
        _db.select(meals).join([
            leftOuterJoin(
              items,
              items.mealId.equalsExp(meals.id) & items.deletedAt.isNull(),
            ),
            leftOuterJoin(photos, photos.mealId.equalsExp(meals.id)),
          ])
          ..where(meals.localDate.equalsValue(day) & meals.deletedAt.isNull())
          ..orderBy([
            OrderingTerm.asc(meals.eatenAt),
            OrderingTerm.asc(items.position),
          ]);
    return query.watch().asyncMap((rows) async {
      final mealRows = <String, MealRow>{};
      final itemRows = <String, List<MealItemRow>>{};
      final photoFiles = <String, String>{};
      for (final row in rows) {
        final meal = row.readTable(meals);
        mealRows[meal.id] = meal;
        final photo = row.readTableOrNull(photos);
        if (photo != null) photoFiles[meal.id] = photo.fileName;
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
            photoPath: switch ((_photos, photoFiles[meal.id])) {
              (final storage?, final fileName?) => storage.pathOf(fileName),
              _ => null,
            },
            items: [
              for (final item in itemRows[meal.id] ?? const <MealItemRow>[])
                _toMealItem(item, portions[item.foodId] ?? const []),
            ],
          ),
      ];
    });
  }

  @override
  Future<void> save(Meal meal) async {
    final photos = _photos;
    if (photos == null) return _db.transaction(() => _saveRows(meal));

    final current = await _photoOf(meal.id);
    final path = meal.photoPath;
    // A cópia acontece antes da transação; se a gravação falhar, o arquivo
    // que sobrar é apagado por [prunePhotos].
    final newFile = path != null && !photos.isStored(path)
        ? await photos.keep(path, mealId: meal.id)
        : null;
    final replaced = newFile != null || path == null ? current : null;

    await _db.transaction(() async {
      await _saveRows(meal);
      if (newFile != null) {
        await _db
            .into(_db.mealPhotos)
            .insertOnConflictUpdate(
              MealPhotosCompanion.insert(mealId: meal.id, fileName: newFile),
            );
      } else if (path == null && current != null) {
        await _deletePhotoRow(meal.id);
      }
    });
    if (replaced != null) await photos.delete(replaced);
  }

  Future<void> _saveRows(Meal meal) async {
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
  }

  @override
  Future<void> delete(Meal meal) async {
    final photo = _photos == null ? null : await _photoOf(meal.id);
    await _db.transaction(() async {
      await _deleteRows(meal);
      if (photo != null) await _deletePhotoRow(meal.id);
    });
    if (photo != null) await _photos!.delete(photo);
  }

  Future<void> _deleteRows(Meal meal) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.meals)..where((m) => m.id.equals(meal.id))).write(
      MealsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
    await (_db.update(_db.mealItems)
          ..where((i) => i.mealId.equals(meal.id) & i.deletedAt.isNull()))
        .write(_tombstone(now));
  }

  /// Limpa fotos de refeições excluídas (inclusive em outro aparelho, que
  /// chegam pela sincronização) e arquivos sem refeição. Roda ao abrir o app.
  Future<void> prunePhotos() async {
    final photos = _photos;
    if (photos == null) return;
    final deleted = _db.selectOnly(_db.meals)
      ..addColumns([_db.meals.id])
      ..where(_db.meals.deletedAt.isNotNull());
    await (_db.delete(
      _db.mealPhotos,
    )..where((p) => p.mealId.isInQuery(deleted))).go();
    final kept = await _db.select(_db.mealPhotos).get();
    await photos.prune({for (final row in kept) row.fileName});
  }

  Future<String?> _photoOf(String mealId) async {
    final row = await (_db.select(
      _db.mealPhotos,
    )..where((p) => p.mealId.equals(mealId))).getSingleOrNull();
    return row?.fileName;
  }

  Future<int> _deletePhotoRow(String mealId) =>
      (_db.delete(_db.mealPhotos)..where((p) => p.mealId.equals(mealId))).go();

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
