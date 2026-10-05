import '../models/enums/portion_unit.dart';
import '../models/food.dart';
import '../models/food_portion.dart';

abstract final class MockFoods {
  static const whiteRice = Food(
    id: 'taco-arroz-branco',
    name: 'Arroz branco cozido',
    emoji: '🍚',
    kcalPer100g: 128,
    carbsPer100g: 28.1,
    proteinPer100g: 2.5,
    fatPer100g: 0.2,
    householdPortions: [FoodPortion(PortionUnit.tablespoon, 25)],
  );

  static const brownRice = Food(
    id: 'taco-arroz-integral',
    name: 'Arroz integral cozido',
    emoji: '🍚',
    kcalPer100g: 124,
    carbsPer100g: 25.8,
    proteinPer100g: 2.6,
    fatPer100g: 1.0,
    householdPortions: [FoodPortion(PortionUnit.tablespoon, 25)],
  );

  static const pintoBeans = Food(
    id: 'taco-feijao-carioca',
    name: 'Feijão carioca cozido',
    emoji: '🫘',
    kcalPer100g: 76,
    carbsPer100g: 13.6,
    proteinPer100g: 4.8,
    fatPer100g: 0.5,
    householdPortions: [FoodPortion(PortionUnit.ladle, 86)],
  );

  static const blackBeans = Food(
    id: 'taco-feijao-preto',
    name: 'Feijão preto cozido',
    emoji: '🫘',
    kcalPer100g: 77,
    carbsPer100g: 14.0,
    proteinPer100g: 4.5,
    fatPer100g: 0.5,
    householdPortions: [FoodPortion(PortionUnit.ladle, 86)],
  );

  static const chickenBreast = Food(
    id: 'taco-frango-peito-grelhado',
    name: 'Peito de frango grelhado',
    emoji: '🍗',
    kcalPer100g: 159,
    carbsPer100g: 0,
    proteinPer100g: 32.0,
    fatPer100g: 2.5,
    householdPortions: [FoodPortion(PortionUnit.unit, 120)],
  );

  static const groundBeef = Food(
    id: 'taco-patinho-grelhado',
    name: 'Carne bovina, patinho grelhado',
    emoji: '🥩',
    kcalPer100g: 219,
    carbsPer100g: 0,
    proteinPer100g: 35.9,
    fatPer100g: 7.3,
    householdPortions: [FoodPortion(PortionUnit.unit, 100)],
  );

  static const egg = Food(
    id: 'taco-ovo-cozido',
    name: 'Ovo de galinha cozido',
    emoji: '🥚',
    kcalPer100g: 146,
    carbsPer100g: 0.6,
    proteinPer100g: 13.3,
    fatPer100g: 9.5,
    householdPortions: [FoodPortion(PortionUnit.unit, 50)],
  );

  static const frenchBread = Food(
    id: 'taco-pao-frances',
    name: 'Pão francês',
    emoji: '🥖',
    kcalPer100g: 300,
    carbsPer100g: 58.6,
    proteinPer100g: 8.0,
    fatPer100g: 3.1,
    householdPortions: [FoodPortion(PortionUnit.unit, 50)],
  );

  static const wholeWheatBread = Food(
    id: 'taco-pao-forma-integral',
    name: 'Pão de forma integral',
    emoji: '🍞',
    kcalPer100g: 253,
    carbsPer100g: 49.9,
    proteinPer100g: 9.4,
    fatPer100g: 3.7,
    householdPortions: [FoodPortion(PortionUnit.slice, 25)],
  );

  static const butter = Food(
    id: 'taco-manteiga',
    name: 'Manteiga com sal',
    emoji: '🧈',
    kcalPer100g: 726,
    carbsPer100g: 0.1,
    proteinPer100g: 0.4,
    fatPer100g: 82.4,
    householdPortions: [FoodPortion(PortionUnit.teaspoon, 5)],
  );

  static const coffee = Food(
    id: 'taco-cafe-coado',
    name: 'Café coado sem açúcar',
    emoji: '☕',
    kcalPer100g: 9,
    carbsPer100g: 1.5,
    proteinPer100g: 0.7,
    fatPer100g: 0.1,
    householdPortions: [FoodPortion(PortionUnit.cup, 100)],
  );

  static const wholeMilk = Food(
    id: 'taco-leite-integral',
    name: 'Leite de vaca integral',
    emoji: '🥛',
    kcalPer100g: 61,
    carbsPer100g: 4.7,
    proteinPer100g: 3.2,
    fatPer100g: 3.3,
    householdPortions: [FoodPortion(PortionUnit.cup, 240)],
  );

  static const banana = Food(
    id: 'taco-banana-prata',
    name: 'Banana prata',
    emoji: '🍌',
    kcalPer100g: 98,
    carbsPer100g: 26.0,
    proteinPer100g: 1.3,
    fatPer100g: 0.1,
    householdPortions: [FoodPortion(PortionUnit.unit, 70)],
  );

  static const apple = Food(
    id: 'taco-maca-fuji',
    name: 'Maçã fuji',
    emoji: '🍎',
    kcalPer100g: 56,
    carbsPer100g: 15.2,
    proteinPer100g: 0.3,
    fatPer100g: 0,
    householdPortions: [FoodPortion(PortionUnit.unit, 130)],
  );

  static const yogurt = Food(
    id: 'taco-iogurte-natural',
    name: 'Iogurte natural integral',
    emoji: '🥣',
    kcalPer100g: 51,
    carbsPer100g: 1.9,
    proteinPer100g: 4.1,
    fatPer100g: 3.0,
    householdPortions: [FoodPortion(PortionUnit.unit, 170)],
  );

  static const oats = Food(
    id: 'taco-aveia-flocos',
    name: 'Aveia em flocos',
    emoji: '🌾',
    kcalPer100g: 394,
    carbsPer100g: 66.6,
    proteinPer100g: 13.9,
    fatPer100g: 8.5,
    householdPortions: [FoodPortion(PortionUnit.tablespoon, 15)],
  );

  static const sweetPotato = Food(
    id: 'taco-batata-doce-cozida',
    name: 'Batata-doce cozida',
    emoji: '🍠',
    kcalPer100g: 77,
    carbsPer100g: 18.4,
    proteinPer100g: 0.6,
    fatPer100g: 0.1,
    householdPortions: [FoodPortion(PortionUnit.unit, 150)],
  );

  static const potato = Food(
    id: 'taco-batata-inglesa-cozida',
    name: 'Batata inglesa cozida',
    emoji: '🥔',
    kcalPer100g: 52,
    carbsPer100g: 11.9,
    proteinPer100g: 1.2,
    fatPer100g: 0,
    householdPortions: [FoodPortion(PortionUnit.unit, 130)],
  );

  static const lettuce = Food(
    id: 'taco-alface-crespa',
    name: 'Alface crespa',
    emoji: '🥬',
    kcalPer100g: 11,
    carbsPer100g: 1.7,
    proteinPer100g: 1.3,
    fatPer100g: 0.2,
  );

  static const tomato = Food(
    id: 'taco-tomate',
    name: 'Tomate',
    emoji: '🍅',
    kcalPer100g: 15,
    carbsPer100g: 3.1,
    proteinPer100g: 1.1,
    fatPer100g: 0.2,
    householdPortions: [FoodPortion(PortionUnit.unit, 100)],
  );

  static const mozzarella = Food(
    id: 'taco-queijo-mucarela',
    name: 'Queijo muçarela',
    emoji: '🧀',
    kcalPer100g: 330,
    carbsPer100g: 3.0,
    proteinPer100g: 22.6,
    fatPer100g: 25.2,
    householdPortions: [FoodPortion(PortionUnit.slice, 20)],
  );

  static const oliveOil = Food(
    id: 'taco-azeite-oliva',
    name: 'Azeite de oliva',
    emoji: '🫒',
    kcalPer100g: 884,
    carbsPer100g: 0,
    proteinPer100g: 0,
    fatPer100g: 100,
    householdPortions: [FoodPortion(PortionUnit.tablespoon, 13)],
  );

  static const all = [
    whiteRice,
    brownRice,
    pintoBeans,
    blackBeans,
    chickenBreast,
    groundBeef,
    egg,
    frenchBread,
    wholeWheatBread,
    butter,
    coffee,
    wholeMilk,
    banana,
    apple,
    yogurt,
    oats,
    sweetPotato,
    potato,
    lettuce,
    tomato,
    mozzarella,
    oliveOil,
  ];
}
