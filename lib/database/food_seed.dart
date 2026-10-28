import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/enums/portion_unit.dart';
import '../models/food.dart';
import '../models/food_portion.dart';

const foodSeedAsset = 'assets/data/foods.json';

Future<List<Food>> loadFoodSeed(AssetBundle bundle) async =>
    parseFoodSeed(await bundle.loadString(foodSeedAsset));

List<Food> parseFoodSeed(String source) => [
  for (final json in jsonDecode(source) as List)
    Food(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      kcalPer100g: (json['kcal'] as num).toDouble(),
      carbsPer100g: (json['carbs'] as num).toDouble(),
      proteinPer100g: (json['protein'] as num).toDouble(),
      fatPer100g: (json['fat'] as num).toDouble(),
      householdPortions: [
        for (final portion in json['portions'] as List)
          FoodPortion(
            PortionUnit.values.byName(portion['unit'] as String),
            (portion['grams'] as num).toDouble(),
          ),
      ],
    ),
];
