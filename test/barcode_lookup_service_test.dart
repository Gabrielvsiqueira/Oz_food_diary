import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/models/enums/food_source.dart';
import 'package:oz_contador_de_calorias/models/enums/portion_unit.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/models/product_info.dart';
import 'package:oz_contador_de_calorias/models/product_lookup_failure.dart';
import 'package:oz_contador_de_calorias/repositories/drift_food_repository.dart';
import 'package:oz_contador_de_calorias/repositories/product_repository.dart';
import 'package:oz_contador_de_calorias/services/barcode_lookup_service.dart';

class _FakeProducts implements ProductRepository {
  final products = <String, ProductInfo>{};
  ProductLookupFailure? failure;
  var calls = 0;

  @override
  Future<ProductInfo?> findByBarcode(String barcode) async {
    calls++;
    if (failure case final failure?) throw failure;
    return products[barcode];
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const code = '7891000100103';
  const condensedMilk = ProductInfo(
    barcode: code,
    name: 'Leite condensado',
    kcalPer100g: 325,
    carbsPer100g: 55,
    proteinPer100g: 7,
    fatPer100g: 8,
    servingGrams: 20,
  );

  late AppDatabase db;
  late DriftFoodRepository foods;
  late _FakeProducts products;
  late BarcodeLookupService lookup;

  setUp(() {
    db = AppDatabase(
      NativeDatabase.memory(),
      foodSeed: () async => MockFoods.all,
    );
    foods = DriftFoodRepository(db);
    products = _FakeProducts();
    lookup = BarcodeLookupService(foods, products);
  });

  tearDown(() => db.close());

  test('produto completo é salvo e passa a aparecer na busca', () async {
    products.products[code] = condensedMilk;

    final result = await lookup.lookup(code);

    final food = (result as BarcodeFoodFound).food;
    expect(food.id, 'off-$code');
    expect(food.kcalPer100g, 325);
    expect(food.portions, [
      FoodPortion.gram,
      const FoodPortion(PortionUnit.serving, 20),
    ]);
    expect((await foods.search('condensado')).single.id, food.id);
    final row = await (db.select(
      db.foods,
    )..where((f) => f.id.equals(food.id))).getSingle();
    expect(row.source, FoodSource.off);
    expect(row.barcode, code);
  });

  test('segunda leitura vem do aparelho, mesmo sem internet', () async {
    products.products[code] = condensedMilk;
    await lookup.lookup(code);
    products.failure = const ProductLookupOfflineFailure();

    final result = await lookup.lookup(code);

    expect(result, isA<BarcodeFoodFound>());
    expect(products.calls, 1);
  });

  test('produto incompleto não é salvo até ser completado', () async {
    products.products[code] = const ProductInfo(
      barcode: code,
      name: 'Leite condensado',
      kcalPer100g: 325,
    );

    final result = await lookup.lookup(code);

    final product = (result as BarcodeProductIncomplete).product;
    expect(product.kcalPer100g, 325);
    expect(await foods.findByBarcode(code), isNull);

    final food = await lookup.save(condensedMilk, source: FoodSource.off);
    expect((await foods.findByBarcode(code))?.id, food.id);
  });

  test('produto desconhecido pode ser cadastrado', () async {
    final result = await lookup.lookup('12345678');
    expect((result as BarcodeProductNotFound).barcode, '12345678');

    await lookup.save(
      const ProductInfo(
        barcode: '12345678',
        name: 'Pão caseiro',
        kcalPer100g: 280,
        carbsPer100g: 50,
        proteinPer100g: 9,
        fatPer100g: 4,
      ),
      source: FoodSource.custom,
    );

    final food = await foods.findByBarcode('12345678');
    expect(food?.id, 'custom-12345678');
    expect(food?.householdPortions, isEmpty);
  });

  test('salvar de novo atualiza o produto e as porções', () async {
    await lookup.save(condensedMilk, source: FoodSource.off);
    await lookup.save(
      const ProductInfo(
        barcode: code,
        name: 'Leite condensado (lata)',
        kcalPer100g: 320,
        carbsPer100g: 55,
        proteinPer100g: 7,
        fatPer100g: 8,
        servingGrams: 30,
      ),
      source: FoodSource.off,
    );

    final food = (await foods.findByBarcode(code))!;
    expect(food.name, 'Leite condensado (lata)');
    expect(food.householdPortions, [
      const FoodPortion(PortionUnit.serving, 30),
    ]);
  });

  test('sem internet, a falha chega para a tela avisar', () {
    products.failure = const ProductLookupOfflineFailure();
    expect(lookup.lookup(code), throwsA(isA<ProductLookupOfflineFailure>()));
  });

  test('sair da conta não apaga os produtos lidos', () async {
    products.products[code] = condensedMilk;
    await lookup.lookup(code);

    await db.clearUserData();

    expect(await foods.findByBarcode(code), isNotNull);
  });
}
