import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/controllers/daily_log_controller.dart';
import 'package:oz_contador_de_calorias/controllers/meal_controller.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/models/enums/meal_type.dart';
import 'package:oz_contador_de_calorias/models/enums/portion_unit.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/models/meal.dart';
import 'package:oz_contador_de_calorias/models/meal_item.dart';
import 'package:oz_contador_de_calorias/repositories/mock_meal_repository.dart';
import 'package:oz_contador_de_calorias/services/date_utils.dart';
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
    late MockMealRepository repository;
    late DailyLogController dailyLog;
    late MealController controller;

    setUp(() {
      repository = MockMealRepository();
      dailyLog = DailyLogController(repository);
      controller = MealController(repository, dailyLog);
    });

    tearDown(() => dailyLog.dispose());

    test('validateItems exige ao menos um alimento', () {
      expect(controller.validateItems(const []), isA<EmptyMealError>());
      expect(
        controller.validateItems(const [
          MealItem(food: rice, portion: FoodPortion.gram, quantity: 1),
        ]),
        null,
      );
    });

    test('addMeal registra no dia de hoje e soma no total do dia', () async {
      await controller.addMeal(
        type: MealType.lunch,
        items: const [
          MealItem(food: rice, portion: FoodPortion.gram, quantity: 100),
        ],
      );
      await pumpEventQueue();
      expect(dailyLog.isTodaySelected, isTrue);
      expect(dailyLog.selectedLog.totalCalories, 128);
    });

    test('addMeal registra no dia aberto na Home, sem trocar o dia', () async {
      dailyLog.goToPreviousDay();
      final yesterday = dailyLog.selectedDate;

      final added = await controller.addMeal(
        type: MealType.dinner,
        items: const [
          MealItem(food: rice, portion: FoodPortion.gram, quantity: 100),
        ],
      );
      await pumpEventQueue();

      expect(isSameDay(added.createdAt, yesterday), isTrue);
      expect(dailyLog.selectedDate, yesterday);
      expect(dailyLog.selectedLog.meals.single.id, added.id);
      dailyLog.selectDate(today());
      await pumpEventQueue();
      expect(dailyLog.selectedLog.meals, isEmpty);
    });

    test('updateMeal substitui os itens da refeição', () async {
      final added = await controller.addMeal(
        type: MealType.lunch,
        items: const [
          MealItem(food: rice, portion: FoodPortion.gram, quantity: 100),
        ],
      );
      await controller.updateMeal(
        added.copyWith(
          items: const [
            MealItem(food: rice, portion: FoodPortion.gram, quantity: 200),
          ],
        ),
      );
      await pumpEventQueue();
      final saved = dailyLog.selectedLog.meals.single;
      expect(saved.id, added.id);
      expect(saved.calories, 256);
    });

    test('deleteMeal tira a refeição do dia', () async {
      final added = await controller.addMeal(
        type: MealType.lunch,
        items: const [
          MealItem(food: rice, portion: FoodPortion.gram, quantity: 100),
        ],
      );
      await controller.deleteMeal(added);
      await pumpEventQueue();
      expect(dailyLog.selectedLog.meals, isEmpty);
    });
  });

  group('virada do dia', () {
    // O relógio do teste: segunda-feira, depois terça.
    final monday = DateTime(2026, 10, 26);
    final tuesday = DateTime(2026, 10, 27);
    late DateTime clock;
    late MockMealRepository repository;
    late DailyLogController dailyLog;
    late MealController controller;

    setUp(() {
      clock = monday;
      repository = MockMealRepository();
      dailyLog = DailyLogController(repository, today: () => clock);
      controller = MealController(repository, dailyLog);
    });

    tearDown(() => dailyLog.dispose());

    Future<Meal> addLunch() => controller.addMeal(
      type: MealType.lunch,
      items: const [
        MealItem(food: rice, portion: FoodPortion.gram, quantity: 100),
      ],
    );

    test('com a Home em "hoje", a refeição vai para o novo dia', () async {
      clock = tuesday;

      final added = await addLunch();

      expect(isSameDay(added.createdAt, tuesday), isTrue);
      expect(dailyLog.selectedDate, tuesday, reason: 'a Home acompanha');
    });

    test('voltar ao app num dia novo leva a Home para hoje', () {
      var notified = 0;
      dailyLog.addListener(() => notified++);
      clock = tuesday;

      dailyLog.followToday();

      expect(dailyLog.selectedDate, tuesday);
      expect(dailyLog.isTodaySelected, isTrue);
      expect(notified, 1);
      dailyLog.followToday();
      expect(notified, 1, reason: 'já está em hoje');
    });

    test('um dia passado escolhido de propósito não muda', () async {
      dailyLog.goToPreviousDay();
      final sunday = dailyLog.selectedDate;
      clock = tuesday;

      dailyLog.followToday();
      final added = await addLunch();

      expect(dailyLog.selectedDate, sunday);
      expect(isSameDay(added.createdAt, sunday), isTrue);
    });
  });
}
