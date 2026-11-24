import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/database/food_seed.dart';
import 'package:oz_contador_de_calorias/models/enums/food_source.dart';
import 'package:oz_contador_de_calorias/models/enums/portion_unit.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/repositories/drift_food_repository.dart';

import 'support/legacy_database.dart';

void main() {
  final foods = parseFoodSeed(File(foodSeedAsset).readAsStringSync());

  Future<List<String>> search(DriftFoodRepository repository, String query) =>
      repository.search(query).then((r) => [for (final f in r) f.name]);

  test('traz a tabela do IBGE, sem os alimentos sem calorias', () {
    expect(foods, hasLength(1566));
    expect(foods.map((f) => f.id).toSet(), hasLength(foods.length));
    expect(foods.map((f) => f.name), isNot(contains('Adoçante artificial')));
  });

  test('valores nutricionais e medidas são válidos', () {
    for (final food in foods) {
      expect(food.name.trim(), isNotEmpty);
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

  test('usa a medida padrão do IBGE como sugerida', () {
    final byName = {for (final food in foods) food.name: food};
    expect(
      byName['Feijão (preto, mulatinho, roxo, rosinha, etc.)']!.defaultPortion,
      const FoodPortion(PortionUnit.ladle, 140),
    );
    expect(
      byName['Pão de sal']!.defaultPortion,
      const FoodPortion(PortionUnit.unit, 50),
    );
    expect(
      byName['Pizza']!.defaultPortion,
      const FoodPortion(PortionUnit.slice, 100),
    );
  });

  test('preparos com os mesmos valores viram um alimento só', () {
    final eggs = foods.where((f) => f.name.startsWith('Ovo de galinha'));
    expect(eggs.map((f) => f.name), [
      'Ovo de galinha',
      'Ovo de galinha, ao alho e óleo',
      'Ovo de galinha, com manteiga ou óleo',
      'Ovo de galinha, frito',
    ]);
    expect(eggs.first.keywords, contains('cozido'));
  });

  group('busca no catálogo inteiro', () {
    late DriftFoodRepository repository;

    setUp(() {
      final db = AppDatabase(
        NativeDatabase.memory(),
        foodSeed: () async => foods,
      );
      addTearDown(db.close);
      repository = DriftFoodRepository(db);
    });

    test('encontra pelo preparo e por nomes regionais', () async {
      expect(await search(repository, 'ovo cozido'), [
        'Ovo de codorna',
        'Ovo de galinha',
      ]);
      expect(await search(repository, 'pao frances'), ['Pão de sal']);
      expect(await search(repository, 'macaxeira'), contains('Aipim'));
    });

    test('nomes que começam pela palavra buscada vêm primeiro', () async {
      final results = await search(repository, 'ovo');
      expect(
        results.take(3),
        containsAll(['Ovo de codorna', 'Ovo de galinha']),
      );
      expect(
        results.indexOf('Ovomaltine'),
        lessThan(results.indexOf('Arroz com ovo')),
      );
    });
  });

  test('a versão 5 troca o catálogo da TACO pelo do IBGE', () async {
    final db = await openLegacyDatabase(
      4,
      foodSeed: () async => foods,
      prepare: (execute) {
        execute(
          "INSERT INTO foods (id, source, name, search_name, emoji, kcal100g, "
          "carbs100g, protein100g, fat100g) VALUES ('taco-1', 'taco', "
          "'Arroz, integral, cozido', 'arroz, integral, cozido', '🍚', 124, "
          "25.8, 2.6, 1)",
        );
        execute(
          "INSERT INTO food_portions (food_id, unit, grams, position) "
          "VALUES ('taco-1', 'servingSpoon', 63, 0)",
        );
        execute(
          "INSERT INTO foods (id, source, barcode, name, search_name, emoji, "
          "kcal100g, carbs100g, protein100g, fat100g) VALUES ('off-789', "
          "'off', '789', 'Iogurte', 'iogurte', '🛒', 60, 5, 3, 3)",
        );
      },
    );

    final rows = await db.select(db.foods).get();
    expect(rows.where((r) => r.id.startsWith('taco-')), isEmpty);
    expect(
      rows.where((r) => r.source == FoodSource.ibge),
      hasLength(foods.length),
    );
    final columns = await db
        .customSelect('SELECT name FROM pragma_table_info(\'foods\')')
        .map((row) => row.read<String>('name'))
        .get();
    expect(columns, isNot(contains('emoji')));
    // Produtos do código de barras continuam no aparelho.
    expect(rows.map((r) => r.id), contains('off-789'));
    expect(
      await (db.select(
        db.foodPortions,
      )..where((p) => p.foodId.equals('taco-1'))).get(),
      isEmpty,
    );
  });
}
