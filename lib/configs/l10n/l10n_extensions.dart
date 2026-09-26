import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../models/enums/activity_level.dart';
import '../../models/enums/gender.dart';
import '../../models/enums/goal_type.dart';
import '../../models/enums/meal_type.dart';
import '../../services/validators.dart';
import 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get localeName => Localizations.localeOf(this).toString();
}

/// Formata números sem casas decimais desnecessárias (175 e não 175.0).
String formatNumber(num value, String locale) =>
    NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    ).format(value);

/// Valor de campo editável: "175" ou "80,5" (pt) / "80.5" (en).
String formatEditableNumber(num value, String locale) {
  if (value == value.roundToDouble()) return value.round().toString();
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: 1,
  ).format(value).replaceAll(RegExp(r'[.,]0$'), '');
}

extension ValidationErrorL10n on ValidationError {
  String message(AppLocalizations l10n) => switch (this) {
    RequiredError() => l10n.errorRequired,
    InvalidNumberError() => l10n.errorInvalidNumber,
    MustBePositiveError() => l10n.errorMustBePositive,
    MustBeNonNegativeError() => l10n.errorMustBeNonNegative,
    OutOfRangeError(:final min, :final max) => l10n.errorOutOfRange(
      min.toString(),
      max.toString(),
    ),
    InvalidEmailError() => l10n.errorInvalidEmail,
    PasswordTooShortError() => l10n.errorPasswordTooShort,
    PasswordMismatchError() => l10n.errorPasswordMismatch,
    InvalidDateError() => l10n.errorInvalidDate,
    AgeOutOfRangeError(:final min, :final max) => l10n.errorAgeOutOfRange(
      min,
      max,
    ),
    CaloriesMismatchError(:final expected) => l10n.errorCaloriesMismatch(
      expected,
    ),
  };
}

/// Adapta um validador de domínio para o `validator` de um `TextFormField`.
FormFieldValidator<String> localizedValidator(
  BuildContext context,
  ValidationError? Function(String?) validator,
) {
  final l10n = context.l10n;
  return (value) => validator(value)?.message(l10n);
}

extension GoalTypeL10n on GoalType {
  String label(AppLocalizations l10n) => switch (this) {
    GoalType.lose => l10n.goalLose,
    GoalType.maintain => l10n.goalMaintain,
    GoalType.gain => l10n.goalGain,
  };

  String title(AppLocalizations l10n) => switch (this) {
    GoalType.lose => l10n.goalLoseTitle,
    GoalType.maintain => l10n.goalMaintainTitle,
    GoalType.gain => l10n.goalGainTitle,
  };

  String get emoji => switch (this) {
    GoalType.lose => '🥦',
    GoalType.maintain => '🍍',
    GoalType.gain => '🥩',
  };
}

extension GenderL10n on Gender {
  String label(AppLocalizations l10n) => switch (this) {
    Gender.male => l10n.genderMale,
    Gender.female => l10n.genderFemale,
  };

  String get emoji => switch (this) {
    Gender.male => '👨',
    Gender.female => '👩',
  };
}

extension ActivityLevelL10n on ActivityLevel {
  String label(AppLocalizations l10n) => switch (this) {
    ActivityLevel.sedentary => l10n.activitySedentary,
    ActivityLevel.light => l10n.activityLight,
    ActivityLevel.moderate => l10n.activityModerate,
    ActivityLevel.heavy => l10n.activityHeavy,
    ActivityLevel.athlete => l10n.activityAthlete,
  };

  String description(AppLocalizations l10n) => switch (this) {
    ActivityLevel.sedentary => l10n.activitySedentaryDescription,
    ActivityLevel.light => l10n.activityLightDescription,
    ActivityLevel.moderate => l10n.activityModerateDescription,
    ActivityLevel.heavy => l10n.activityHeavyDescription,
    ActivityLevel.athlete => l10n.activityAthleteDescription,
  };

  String get emoji => switch (this) {
    ActivityLevel.sedentary => '🪑',
    ActivityLevel.light => '🌿',
    ActivityLevel.moderate => '⚡',
    ActivityLevel.heavy => '🔥',
    ActivityLevel.athlete => '🏋️',
  };
}

extension MealTypeL10n on MealType {
  String label(AppLocalizations l10n) => switch (this) {
    MealType.breakfast => l10n.mealTypeBreakfast,
    MealType.lunch => l10n.mealTypeLunch,
    MealType.dinner => l10n.mealTypeDinner,
    MealType.snack => l10n.mealTypeSnack,
  };

  String get emoji => switch (this) {
    MealType.breakfast => '🍞',
    MealType.lunch => '🍛',
    MealType.dinner => '🍝',
    MealType.snack => '🍎',
  };
}
