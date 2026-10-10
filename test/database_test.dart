import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/mocks/mock_user_profile.dart';
import 'package:oz_contador_de_calorias/models/enums/meal_type.dart';
import 'package:oz_contador_de_calorias/models/enums/portion_unit.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/models/meal.dart';
import 'package:oz_contador_de_calorias/models/meal_item.dart';
import 'package:oz_contador_de_calorias/models/nutrition_goal.dart';
import 'package:oz_contador_de_calorias/repositories/drift_food_repository.dart';
import 'package:oz_contador_de_calorias/repositories/drift_meal_repository.dart';
import 'package:oz_contador_de_calorias/repositories/drift_profile_repository.dart';
import 'package:oz_contador_de_calorias/repositories/local_session_repository.dart';
import 'package:oz_contador_de_calorias/services/date_utils.dart';

void main() {
  const userId = '11111111-1111-1111-1111-111111111111';
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(
      NativeDatabase.memory(),
      foodSeed: () async => MockFoods.all,
    );
  });

  tearDown(() => db.close());

  group('DriftFoodRepository', () {
    test('carrega o catálogo inicial na criação do banco', () async {
      final results = await DriftFoodRepository(db).search('');
      expect(results, hasLength(MockFoods.all.length));
      expect(results.first.name, 'Alface crespa');
    });

    test('ignora acentos, maiúsculas e ordem das palavras', () async {
      final results = await DriftFoodRepository(db).search('  COZIDO feijao ');
      expect(results.map((f) => f.name), [
        'Feijão carioca cozido',
        'Feijão preto cozido',
      ]);
    });

    test('traz as medidas caseiras na ordem do catálogo', () async {
      final [beans] = await DriftFoodRepository(db).search('feijao carioca');
      expect(beans.defaultPortion, const FoodPortion(PortionUnit.ladle, 86));
    });

    test('trata % e _ como texto, não como curinga', () async {
      expect(await DriftFoodRepository(db).search('%'), isEmpty);
      expect(await DriftFoodRepository(db).search('_'), isEmpty);
    });
  });

  group('DriftMealRepository', () {
    late DriftMealRepository repository;
    final lunchTime = DateTime.now().copyWith(hour: 12, minute: 30);

    Meal lunch(List<MealItem> items) => Meal(
      id: 'meal-1',
      type: MealType.lunch,
      items: items,
      createdAt: lunchTime,
    );

    const rice = MealItem(
      food: MockFoods.whiteRice,
      portion: FoodPortion(PortionUnit.tablespoon, 25),
      quantity: 4,
    );
    const beans = MealItem(
      food: MockFoods.pintoBeans,
      portion: FoodPortion(PortionUnit.ladle, 86),
      quantity: 1,
    );

    setUp(() => repository = DriftMealRepository(db));

    Future<List<Meal>> mealsToday() => repository.watchMealsOn(today()).first;

    test('salva e lê a refeição com a cópia do alimento', () async {
      await repository.save(lunch(const [rice, beans]));

      final [meal] = await mealsToday();
      expect(meal.type, MealType.lunch);
      expect(meal.createdAt, lunchTime);
      expect(meal.items.map((i) => i.food.name), [
        'Arroz branco cozido',
        'Feijão carioca cozido',
      ]);
      expect(meal.items.first.grams, 100);
      expect(meal.calories, lunch(const [rice, beans]).calories);
    });

    test('não lista refeições de outros dias', () async {
      await repository.save(lunch(const [rice]));
      final yesterday = today().subtract(const Duration(days: 1));
      expect(await repository.watchMealsOn(yesterday).first, isEmpty);
    });

    test('salvar de novo não duplica refeição nem itens', () async {
      await repository.save(lunch(const [rice, beans]));
      await repository.save(lunch(const [rice, beans]));

      expect(await mealsToday(), hasLength(1));
      expect(await db.select(db.mealItems).get(), hasLength(2));
    });

    test(
      'editar com menos itens marca os que sobraram como excluídos',
      () async {
        await repository.save(lunch(const [rice, beans]));
        await repository.save(lunch(const [beans]));

        final [meal] = await mealsToday();
        expect(meal.items.single.food.name, 'Feijão carioca cozido');
        final rows = await db.select(db.mealItems).get();
        expect(rows, hasLength(2));
        expect(rows.where((r) => r.deletedAt != null), hasLength(1));
      },
    );

    test('excluir é lógico e marca para sincronizar', () async {
      await repository.save(lunch(const [rice]));
      await (db.update(
        db.meals,
      )).write(const MealsCompanion(isDirty: Value(false)));
      await repository.delete(lunch(const [rice]));

      expect(await mealsToday(), isEmpty);
      final row = await db.select(db.meals).getSingle();
      expect(row.deletedAt, isNotNull);
      expect(row.isDirty, isTrue);
    });

    test('a lista do dia atualiza sozinha a cada gravação', () async {
      final emissions = repository.watchMealsOn(today());
      final expectation = expectLater(
        emissions.map((meals) => meals.length),
        emitsInOrder([0, 1]),
      );
      await pumpEventQueue();
      await repository.save(lunch(const [rice]));
      await expectation;
    });
  });

  group('DriftProfileRepository', () {
    late DriftProfileRepository repository;
    const goal = NutritionGoal(
      caloriesTarget: 2000,
      carbsTargetG: 200,
      proteinTargetG: 150,
      fatTargetG: 60,
    );

    setUp(() => repository = DriftProfileRepository(db));

    test('sem conta salva, load retorna null', () async {
      expect(await repository.load(), isNull);
    });

    test('create guarda perfil, peso e meta', () async {
      await repository.create(mockUserProfile, goal, userId: userId);

      final data = (await repository.load())!;
      expect(data.profile.name, mockUserProfile.name);
      expect(data.profile.birthDate, mockUserProfile.birthDate);
      expect(data.profile.weight, mockUserProfile.weight);
      expect(data.goal.caloriesTarget, 2000);
    });

    test('mudar o peso no mesmo dia atualiza a medição de hoje', () async {
      await repository.create(mockUserProfile, goal, userId: userId);
      await repository.updateProfile(mockUserProfile.copyWith(weightKg: 93));
      await repository.updateProfile(mockUserProfile.copyWith(weightKg: 92));

      expect((await repository.load())!.profile.weight, 92);
      expect(await db.select(db.weightEntries).get(), hasLength(1));
    });

    test('salvar a meta no mesmo dia não cria histórico duplicado', () async {
      await repository.create(mockUserProfile, goal, userId: userId);
      await repository.saveGoal(goal.copyWith(caloriesTarget: 1800));

      expect((await repository.load())!.goal.caloriesTarget, 1800);
      expect(await db.select(db.nutritionGoals).get(), hasLength(1));
    });

    test('a meta vigente é a mais recente até hoje', () async {
      await repository.create(mockUserProfile, goal, userId: userId);
      final [current] = await db.select(db.nutritionGoals).get();
      await db
          .into(db.nutritionGoals)
          .insert(
            current.copyWith(
              id: 'older',
              calories: 2500,
              effectiveFrom: today().subtract(const Duration(days: 30)),
            ),
          );

      expect((await repository.load())!.goal.caloriesTarget, 2000);
    });

    test('create substitui os dados de uma conta anterior', () async {
      await repository.create(mockUserProfile, goal, userId: userId);
      await DriftMealRepository(db).save(
        Meal(
          id: 'old',
          type: MealType.lunch,
          items: const [
            MealItem(
              food: MockFoods.egg,
              portion: FoodPortion.gram,
              quantity: 50,
            ),
          ],
          createdAt: DateTime.now(),
        ),
      );
      await repository.create(
        mockUserProfile.copyWith(name: 'Nova'),
        goal,
        userId: userId,
      );

      expect((await repository.load())!.profile.name, 'Nova');
      expect(await db.select(db.profiles).get(), hasLength(1));
      expect(await db.select(db.meals).get(), isEmpty);
    });
  });

  group('LocalSessionRepository', () {
    late LocalSessionRepository session;

    setUp(() {
      session = LocalSessionRepository(
        db,
        profiles: DriftProfileRepository(db),
        meals: DriftMealRepository(db),
      );
    });

    test('login sem conta salva entra na conta de demonstração', () async {
      expect(await session.currentUser(), isNull);
      await session.signIn(email: 'a@b.com', password: '12345678');

      expect(await session.currentUser(), isNotNull);
      expect(await db.select(db.meals).get(), isNotEmpty);
    });

    test('logout apaga os dados do usuário e mantém o catálogo', () async {
      await session.signIn(email: 'a@b.com', password: '12345678');
      await session.signOut();

      expect(await session.currentUser(), isNull);
      expect(await db.select(db.meals).get(), isEmpty);
      expect(await db.select(db.mealItems).get(), isEmpty);
      expect(await db.select(db.foods).get(), hasLength(MockFoods.all.length));
    });
  });
}
