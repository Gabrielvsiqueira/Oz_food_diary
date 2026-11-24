import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/database/food_seed.dart';
import 'package:oz_contador_de_calorias/models/food.dart';
import 'package:oz_contador_de_calorias/widgets/charts/macro_split_bar.dart';

const _egg = Food(
  id: 'ovo',
  name: 'Ovo de galinha',
  kcalPer100g: 155,
  carbsPer100g: 1.1,
  proteinPer100g: 12.6,
  fatPer100g: 10.6,
);

void main() {
  test('divide as calorias pelos macros (4, 4 e 9 kcal por grama)', () {
    final split = MacroSplit.of(_egg)!;
    // 4,4 + 50,4 + 95,4 = 150,2 kcal
    expect(split.carbs, closeTo(0.029, 0.001));
    expect(split.protein, closeTo(0.336, 0.001));
    expect(split.fat, closeTo(0.635, 0.001));
    expect(split.description, 'Carboidratos 3%, Proteínas 34%, Gorduras 64%');
  });

  test('alimento sem macros não tem divisão', () {
    const water = Food(
      id: 'agua',
      name: 'Água',
      kcalPer100g: 0,
      carbsPer100g: 0,
      proteinPer100g: 0,
      fatPer100g: 0,
    );
    expect(MacroSplit.of(water), isNull);
  });

  test('nas destiladas as calorias vêm do álcool', () {
    const rum = Food(
      id: 'rum',
      name: 'Rum',
      kcalPer100g: 230.2,
      carbsPer100g: 0,
      proteinPer100g: 0,
      fatPer100g: 0,
    );
    expect(MacroSplit.of(rum)!.alcohol, 1);
  });

  test('na cerveja o álcool aparece junto com o carboidrato', () {
    const beer = Food(
      id: 'cerveja',
      name: 'Cerveja',
      kcalPer100g: 43.2,
      carbsPer100g: 3.6,
      proteinPer100g: 0.5,
      fatPer100g: 0,
    );
    final split = MacroSplit.of(beer)!;
    // 14,4 + 2 = 16,4 kcal de macros; 26,8 kcal de álcool.
    expect(split.alcohol, closeTo(0.62, 0.01));
    expect(split.carbs, closeTo(0.33, 0.01));
  });

  test('no catálogo, só bebidas alcoólicas ganham a faixa de álcool', () {
    final foods = parseFoodSeed(File(foodSeedAsset).readAsStringSync());
    final withAlcohol = {
      for (final food in foods)
        if ((MacroSplit.of(food)?.alcohol ?? 0) > 0) food.name,
    };
    expect(withAlcohol, containsAll(['Rum', 'Cachaça', 'Vinho', 'Chopp']));
    const alcoholic = [
      'aguardente',
      'bebida alcoólica',
      'cachaça',
      'catuaba',
      'caxiri',
      'cerveja',
      'champanhe',
      'chopp',
      'conhaque',
      'drink',
      'licor',
      'martini',
      'rum',
      'sidra',
      'uísque',
      'vinho',
      'vodka',
      'whisky',
      'coquetel',
      'batida',
    ];
    for (final name in withAlcohol) {
      expect(
        alcoholic.any(name.toLowerCase().startsWith),
        isTrue,
        reason: name,
      );
    }
  });

  testWidgets('sem calorias para dividir, a barra não aparece', (tester) async {
    const coffee = Food(
      id: 'cafe',
      name: 'Café',
      kcalPer100g: 1,
      carbsPer100g: 0,
      proteinPer100g: 0,
      fatPer100g: 0,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MacroSplitBar(food: coffee, showLegend: true)),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(MacroSplitBar),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('a barra é lida pelo leitor de tela com as porcentagens', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MacroSplitBar(food: _egg, showLegend: true)),
      ),
    );
    expect(
      find.bySemanticsLabel('Carboidratos 3%, Proteínas 34%, Gorduras 64%'),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
