import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../models/enums/activity_level.dart';
import '../../models/enums/gender.dart';
import '../../models/enums/goal_type.dart';
import '../../models/enums/meal_type.dart';
import '../../models/enums/portion_unit.dart';
import '../../models/food_portion.dart';
import '../../models/meal_item.dart';
import '../../services/validators.dart';
import 'app_strings.dart';

export 'app_strings.dart';

const appLocale = 'pt_BR';

String formatNumber(num value) => NumberFormat.decimalPatternDigits(
  locale: appLocale,
  decimalDigits: 0,
).format(value);

String formatEditableNumber(num value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value
      .toStringAsFixed(1)
      .replaceAll(RegExp(r'\.0$'), '')
      .replaceAll('.', ',');
}

extension ValidationErrorLabels on ValidationError {
  String get message => switch (this) {
    RequiredError() => AppStrings.errorRequired,
    InvalidNumberError() => AppStrings.errorInvalidNumber,
    MustBePositiveError() => AppStrings.errorMustBePositive,
    MustBeNonNegativeError() => AppStrings.errorMustBeNonNegative,
    OutOfRangeError(:final min, :final max) => AppStrings.errorOutOfRange(
      min.toString(),
      max.toString(),
    ),
    InvalidEmailError() => AppStrings.errorInvalidEmail,
    PasswordTooShortError() => AppStrings.errorPasswordTooShort,
    PasswordMismatchError() => AppStrings.errorPasswordMismatch,
    InvalidDateError() => AppStrings.errorInvalidDate,
    AgeOutOfRangeError(:final min, :final max) => AppStrings.errorAgeOutOfRange(
      min,
      max,
    ),
    EmptyMealError() => AppStrings.errorEmptyMeal,
    FoodQuantityTooLargeError(:final maxGrams) =>
      AppStrings.errorFoodQuantityTooLarge(maxGrams),
  };
}

FormFieldValidator<String> fieldValidator(
  ValidationError? Function(String?) validator,
) =>
    (value) => validator(value)?.message;

extension GoalTypeLabels on GoalType {
  String get label => switch (this) {
    GoalType.lose => AppStrings.goalLose,
    GoalType.maintain => AppStrings.goalMaintain,
    GoalType.gain => AppStrings.goalGain,
  };

  String get title => switch (this) {
    GoalType.lose => AppStrings.goalLoseTitle,
    GoalType.maintain => AppStrings.goalMaintainTitle,
    GoalType.gain => AppStrings.goalGainTitle,
  };

  String get emoji => switch (this) {
    GoalType.lose => '🥦',
    GoalType.maintain => '🍍',
    GoalType.gain => '🥩',
  };
}

extension GenderLabels on Gender {
  String get label => switch (this) {
    Gender.male => AppStrings.genderMale,
    Gender.female => AppStrings.genderFemale,
  };

  String get emoji => switch (this) {
    Gender.male => '👨',
    Gender.female => '👩',
  };
}

extension ActivityLevelLabels on ActivityLevel {
  String get label => switch (this) {
    ActivityLevel.sedentary => AppStrings.activitySedentary,
    ActivityLevel.light => AppStrings.activityLight,
    ActivityLevel.moderate => AppStrings.activityModerate,
    ActivityLevel.heavy => AppStrings.activityHeavy,
    ActivityLevel.athlete => AppStrings.activityAthlete,
  };

  String get description => switch (this) {
    ActivityLevel.sedentary => AppStrings.activitySedentaryDescription,
    ActivityLevel.light => AppStrings.activityLightDescription,
    ActivityLevel.moderate => AppStrings.activityModerateDescription,
    ActivityLevel.heavy => AppStrings.activityHeavyDescription,
    ActivityLevel.athlete => AppStrings.activityAthleteDescription,
  };

  String get emoji => switch (this) {
    ActivityLevel.sedentary => '🪑',
    ActivityLevel.light => '🌿',
    ActivityLevel.moderate => '⚡',
    ActivityLevel.heavy => '🔥',
    ActivityLevel.athlete => '🏋️',
  };
}

extension MealTypeLabels on MealType {
  String get label => switch (this) {
    MealType.breakfast => AppStrings.mealTypeBreakfast,
    MealType.lunch => AppStrings.mealTypeLunch,
    MealType.dinner => AppStrings.mealTypeDinner,
    MealType.snack => AppStrings.mealTypeSnack,
  };

  String get emoji => switch (this) {
    MealType.breakfast => '🍞',
    MealType.lunch => '🍛',
    MealType.dinner => '🍝',
    MealType.snack => '🍎',
  };
}

extension PortionUnitLabels on PortionUnit {
  String label(num count) => switch (this) {
    PortionUnit.gram => AppStrings.portionGram(count),
    PortionUnit.unit => AppStrings.portionUnit(count),
    PortionUnit.slice => AppStrings.portionSlice(count),
    PortionUnit.tablespoon => AppStrings.portionTablespoon(count),
    PortionUnit.teaspoon => AppStrings.portionTeaspoon(count),
    PortionUnit.cup => AppStrings.portionCup(count),
    PortionUnit.ladle => AppStrings.portionLadle(count),
    PortionUnit.servingSpoon => AppStrings.portionServingSpoon(count),
  };
}

extension FoodPortionLabels on FoodPortion {
  String get optionLabel => unit == PortionUnit.gram
      ? unit.label(2)
      : '${unit.label(1)} (${formatEditableNumber(grams)} g)';
}

extension MealItemLabels on MealItem {
  String get quantityLabel {
    final gramsText = '${formatEditableNumber(grams)} g';
    if (portion.unit == PortionUnit.gram) return gramsText;
    final amount = formatEditableNumber(quantity);
    return '$amount ${portion.unit.label(quantity)} · $gramsText';
  }
}
