import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/database/food_seed.dart';
import 'package:oz_contador_de_calorias/models/enums/portion_unit.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/repositories/drift_food_repository.dart';

void main() {
  final foods = parseFoodSeed(File(foodSeedAsset).readAsStringSync());

  test('traz a TACO completa, sem os alimentos em reavaliação', () {
    expect(foods, hasLength(592));
    expect(foods.map((f) => f.id).toSet(), hasLength(foods.length));
    expect(
      foods.map((f) => f.name),
      isNot(contains('Leite, de vaca, integral')),
    );
  });

  test('valores nutricionais e medidas são válidos', () {
    for (final food in foods) {
      expect(food.name.trim(), isNotEmpty);
      expect(food.emoji, isNotEmpty);
      for (final value in [
        food.kcalPer100g,
        food.carbsPer100g,
        food.proteinPer100g,
        food.fatPer100g,
      ]) {
        expect(value, greaterThanOrEqualTo(0), reason: food.name);
      }
      for (final portion in food.householdPortions) {
        expect(portion.unit, isNot(PortionUnit.gram), reason: food.name);
        expect(portion.grams, greaterThan(0), reason: food.name);
      }
    }
  });

  test('usa as medidas caseiras do IBGE nos alimentos comuns', () {
    final byName = {for (final food in foods) food.name: food};
    expect(
      byName['Arroz, tipo 1, cozido']!.defaultPortion,
      const FoodPortion(PortionUnit.servingSpoon, 45),
    );
    expect(
      byName['Feijão, carioca, cozido']!.defaultPortion,
      const FoodPortion(PortionUnit.ladle, 140),
    );
    expect(
      byName['Pão, trigo, francês']!.defaultPortion,
      const FoodPortion(PortionUnit.unit, 50),
    );
    expect(byName['Alface, crespa, crua']!.defaultPortion, FoodPortion.gram);
  });

  test('o catálogo inteiro entra no banco e é encontrado pela busca', () async {
    final db = AppDatabase(
      NativeDatabase.memory(),
      foodSeed: () async => foods,
    );
    addTearDown(db.close);
    final results = await DriftFoodRepository(db).search('feijao carioca');
    expect(results.map((f) => f.name), [
      'Feijão, carioca, cozido',
      'Feijão, carioca, cru',
    ]);
    expect(results.first.defaultPortion.unit, PortionUnit.ladle);
  });
}
