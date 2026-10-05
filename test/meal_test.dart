import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/controllers/daily_log_controller.dart';
import 'package:oz_contador_de_calorias/controllers/meal_controller.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/models/enums/meal_type.dart';
import 'package:oz_contador_de_calorias/models/enums/portion_unit.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/models/meal.dart';
import 'package:oz_contador_de_calorias/models/meal_item.dart';
import 'package:oz_contador_de_calorias/services/validators.dart';

void main() {
  const rice = MockFoods.whiteRice; // 128 kcal, 28.1 C, 2.5 P, 0.2 G / 100 g
  const chicken = MockFoods.chickenBreast; // 159 kcal, 0 C, 32 P, 2.5 G

  group('MealItem', () {
    test('calcula nutrientes proporcionais aos gramas', () {
      const item = MealItem(
        food: rice,
        portion: FoodPortion.gram,
        quantity: 150,
      );
      expect(item.grams, 150);
      expect(item.calories, closeTo(192, 0.001));
      expect(item.carbsG, closeTo(42.15, 0.001));
      expect(item.proteinG, closeTo(3.75, 0.001));
    });

    test('converte medidas caseiras em gramas', () {
      const spoon = FoodPortion(PortionUnit.tablespoon, 25);
      const item = MealItem(food: rice, portion: spoon, quantity: 4);
      expect(item.grams, 100);
      expect(item.calories, closeTo(128, 0.001));
    });
  });

  group('Meal', () {
    Meal meal(List<MealItem> items) => Meal(
      id: 'm',
      type: MealType.lunch,
      items: items,
      createdAt: DateTime.now(),
    );

    test('soma calorias e macros dos alimentos', () {
      final m = meal(const [
        MealItem(food: rice, portion: FoodPortion.gram, quantity: 100),
        MealItem(food: chicken, portion: FoodPortion.gram, quantity: 120),
      ]);
      expect(m.calories, 319); // 128 + 190,8
      expect(m.proteinG, closeTo(40.9, 0.001));
      expect(m.summary, 'Arroz branco cozido, Peito de frango grelhado');
    });

    test('a lista de itens não pode ser alterada por fora', () {
      final m = meal(const []);
      expect(
        () => m.items.add(
          const MealItem(food: rice, portion: FoodPortion.gram, quantity: 1),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('Food', () {
    test('sempre oferece gramas e sugere a medida caseira', () {
      expect(chicken.portions.first, FoodPortion.gram);
      expect(chicken.defaultPortion.unit, PortionUnit.unit);
      expect(MockFoods.lettuce.defaultPortion, FoodPortion.gram);
    });
  });

  group('Validators.foodQuantity', () {
    test('aceita decimal com vírgula dentro do limite', () {
      expect(Validators.foodQuantity('1,5', 25), null);
    });

    test('rejeita vazio, zero e mais de 5 kg', () {
      expect(Validators.foodQuantity('', 1), isA<RequiredError>());
      expect(Validators.foodQuantity('0', 1), isA<MustBePositiveError>());
      expect(
        Validators.foodQuantity('201', 25),
        isA<FoodQuantityTooLargeError>(),
      );
    });
  });

  group('MealController', () {
    late DailyLogController dailyLog;
    late MealController controller;

    setUp(() {
      dailyLog = DailyLogController();
      controller = MealController(dailyLog);
    });

    test('validateItems exige ao menos um alimento', () {
      expect(controller.validateItems(const []), isA<EmptyMealError>());
      expect(
        controller.validateItems(const [
          MealItem(food: rice, portion: FoodPortion.gram, quantity: 1),
        ]),
        null,
      );
    });

    test('addMeal registra no dia de hoje e soma no total do dia', () {
      final before = dailyLog.logFor(DateTime.now()).totalCalories;
      controller.addMeal(
        type: MealType.lunch,
        items: const [
          MealItem(food: rice, portion: FoodPortion.gram, quantity: 100),
        ],
      );
      expect(dailyLog.logFor(DateTime.now()).totalCalories, before + 128);
    });

    test('updateMeal substitui os itens da refeição', () {
      final added = controller.addMeal(
        type: MealType.lunch,
        items: const [
          MealItem(food: rice, portion: FoodPortion.gram, quantity: 100),
        ],
      );
      controller.updateMeal(
        added.copyWith(
          items: const [
            MealItem(food: rice, portion: FoodPortion.gram, quantity: 200),
          ],
        ),
      );
      final saved = dailyLog
          .logFor(DateTime.now())
          .meals
          .firstWhere((m) => m.id == added.id);
      expect(saved.calories, 256);
    });
  });
}
