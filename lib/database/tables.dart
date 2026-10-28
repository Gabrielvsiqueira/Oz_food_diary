import 'package:drift/drift.dart';

import '../models/enums/activity_level.dart';
import '../models/enums/food_source.dart';
import '../models/enums/gender.dart';
import '../models/enums/goal_type.dart';
import '../models/enums/meal_type.dart';
import '../models/enums/portion_unit.dart';
import 'date_only_converter.dart';

/// Colunas de sincronização das tabelas de dados do usuário
/// (ver docs/arquitetura.md, seção 4).
mixin SyncColumns on Table {
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
}

@DataClassName('ProfileRow')
class Profiles extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get goal => textEnum<GoalType>()();
  TextColumn get gender => textEnum<Gender>()();
  TextColumn get birthDate => text().map(const DateOnlyConverter())();
  TextColumn get activityLevel => textEnum<ActivityLevel>()();
  RealColumn get heightCm => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NutritionGoalRow')
class NutritionGoals extends Table with SyncColumns {
  TextColumn get id => text()();
  IntColumn get calories => integer()();
  RealColumn get carbsG => real()();
  RealColumn get proteinG => real()();
  RealColumn get fatG => real()();
  TextColumn get effectiveFrom => text().map(const DateOnlyConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {effectiveFrom},
  ];
}

@DataClassName('WeightEntryRow')
class WeightEntries extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get measuredOn => text().map(const DateOnlyConverter())();
  RealColumn get weightKg => real()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {measuredOn},
  ];
}

@TableIndex(name: 'meals_local_date', columns: {#localDate})
@DataClassName('MealRow')
class Meals extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get type => textEnum<MealType>()();
  DateTimeColumn get eatenAt => dateTime()();
  TextColumn get localDate => text().map(const DateOnlyConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cada item guarda uma cópia do alimento: correções na base não alteram o
/// histórico de refeições.
@TableIndex(name: 'meal_items_meal_id', columns: {#mealId})
@DataClassName('MealItemRow')
class MealItems extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get mealId => text().references(Meals, #id)();
  TextColumn get foodId => text().nullable()();
  IntColumn get position => integer()();
  TextColumn get foodName => text()();
  TextColumn get foodEmoji => text()();
  RealColumn get kcal100g => real()();
  RealColumn get carbs100g => real()();
  RealColumn get protein100g => real()();
  RealColumn get fat100g => real()();
  TextColumn get portionUnit => textEnum<PortionUnit>()();
  RealColumn get portionGrams => real()();
  RealColumn get quantity => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FoodRow')
class Foods extends Table {
  TextColumn get id => text()();
  TextColumn get source => textEnum<FoodSource>()();
  TextColumn get sourceRef => text().nullable()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get name => text()();

  /// Nome minúsculo e sem acentos, usado na busca.
  TextColumn get searchName => text()();
  TextColumn get emoji => text()();
  RealColumn get kcal100g => real()();
  RealColumn get carbs100g => real()();
  RealColumn get protein100g => real()();
  RealColumn get fat100g => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FoodPortionRow')
class FoodPortions extends Table {
  TextColumn get foodId => text().references(Foods, #id)();
  TextColumn get unit => textEnum<PortionUnit>()();
  RealColumn get grams => real()();

  /// Ordem de exibição; a primeira é a medida sugerida.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {foodId, unit, grams};
}
