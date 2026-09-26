// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Oz';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonNo => 'No';

  @override
  String get commonYes => 'Yes';

  @override
  String get errorRequired => 'Required field';

  @override
  String get errorInvalidNumber => 'Enter a valid number';

  @override
  String get errorMustBePositive => 'Enter a value greater than zero';

  @override
  String get errorMustBeNonNegative => 'The value can\'t be negative';

  @override
  String errorOutOfRange(String min, String max) {
    return 'Enter a value between $min and $max';
  }

  @override
  String get errorInvalidEmail => 'Enter a valid email';

  @override
  String get errorPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get errorPasswordMismatch => 'Passwords don\'t match';

  @override
  String get errorInvalidDate => 'Enter a valid date';

  @override
  String errorAgeOutOfRange(int min, int max) {
    return 'Age must be between $min and $max years';
  }

  @override
  String errorCaloriesMismatch(int expected) {
    return 'Calories don\'t match the macros (≈ $expected kcal)';
  }

  @override
  String get goalLose => 'Lose weight';

  @override
  String get goalMaintain => 'Maintain weight';

  @override
  String get goalGain => 'Gain weight';

  @override
  String get goalLoseTitle => 'Lose Weight';

  @override
  String get goalMaintainTitle => 'Maintain Weight';

  @override
  String get goalGainTitle => 'Gain Weight';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activitySedentaryDescription => 'I don\'t exercise';

  @override
  String get activityLight => 'Light';

  @override
  String get activityLightDescription => '1 to 2 times a week';

  @override
  String get activityModerate => 'Moderate';

  @override
  String get activityModerateDescription => '3 to 5 times a week';

  @override
  String get activityHeavy => 'Heavy';

  @override
  String get activityHeavyDescription => '6 to 7 times a week';

  @override
  String get activityAthlete => 'Athlete';

  @override
  String get activityAthleteDescription => 'Twice a day';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get calories => 'Calories';

  @override
  String get carbs => 'Carbs';

  @override
  String get protein => 'Protein';

  @override
  String get fat => 'Fat';

  @override
  String get kcal => 'Kcal';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitGrams => 'g';

  @override
  String get unitCm => 'cm';

  @override
  String get unitKg => 'kg';

  @override
  String get onboardingGoalTitle => 'What\'s your goal?';

  @override
  String get onboardingGoalSubtitle =>
      'What do you want to achieve with your diet?';

  @override
  String get onboardingGenderTitle => 'What\'s your gender';

  @override
  String get onboardingGenderSubtitle => 'Your gender affects the kind of diet';

  @override
  String get onboardingBirthdateTitle => 'When were you born?';

  @override
  String get onboardingBirthdateSubtitle =>
      'Each age group responds in its own way';

  @override
  String get onboardingBirthdateHint => 'DD/MM/YYYY';

  @override
  String get onboardingHeightTitle => 'How tall are you?';

  @override
  String get onboardingWeightTitle => 'How much do you weigh?';

  @override
  String get onboardingEstimateSubtitle => 'An estimate is fine';

  @override
  String get onboardingActivityTitle => 'What\'s your activity level?';

  @override
  String get onboardingAccountTitle => 'Create your account';

  @override
  String get onboardingAccountSubtitle => 'So you can track your progress';

  @override
  String get onboardingCreateAccount => 'Create account';

  @override
  String get onboardingLoadingTitle => 'We\'re personalizing the app for you';

  @override
  String get onboardingResultTitlePrefix => 'Your diet plan to';

  @override
  String get onboardingResultTitleSuffix => 'is ready!';

  @override
  String get onboardingResultDescription =>
      'This is the daily recommendation for your plan. Don\'t worry, you can edit it later if you want.';

  @override
  String get onboardingResultStart => 'Start my plan';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'John Smith';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'johnsmith@gmail.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get birthDateLabel => 'Date of Birth';

  @override
  String get heightLabel => 'Height';

  @override
  String get weightLabel => 'Weight';

  @override
  String get sexLabel => 'Sex';

  @override
  String get tabHome => 'Home';

  @override
  String get tabGoals => 'Goals';

  @override
  String get tabProfile => 'Profile';

  @override
  String get homeGreeting => 'Hi, 👋';

  @override
  String get homeToday => 'Today';

  @override
  String get homeYesterday => 'Yesterday';

  @override
  String get homeMealsSection => 'MEALS';

  @override
  String get homeNoMealsTitle => 'No meals logged';

  @override
  String get homeNoMealsToday => 'Tap + to log your first meal of the day';

  @override
  String get homeNoMealsPast => 'Nothing was logged on this day';

  @override
  String get homePreviousDay => 'Previous day';

  @override
  String get homeNextDay => 'Next day';

  @override
  String get homeAddMeal => 'New meal';

  @override
  String get mealNewTitle => 'New meal';

  @override
  String get mealEditTitle => 'Edit meal';

  @override
  String get mealTypeLabel => 'Type';

  @override
  String get mealDescriptionLabel => 'Description';

  @override
  String get mealDescriptionHint => 'Bread, butter and coffee';

  @override
  String mealMacrosEstimate(int value) {
    return 'From macros: ≈ $value kcal';
  }

  @override
  String get mealDeleteTitle => 'Delete meal?';

  @override
  String get mealDeleteMessage => 'This action can\'t be undone.';

  @override
  String get mealSaved => 'Meal saved';

  @override
  String get mealDeleted => 'Meal deleted';

  @override
  String get goalsTitle => 'Your Goals';

  @override
  String get goalsSaved => 'Goals updated';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSaved => 'Profile updated';

  @override
  String get profileRecalculateTitle => 'Are you sure?';

  @override
  String get profileRecalculateMessage =>
      'You changed your weight or height. Your calorie and macro goals will be recalculated.';

  @override
  String get profileGoalsRecalculated =>
      'Profile updated and goals recalculated';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileLogoutTitle => 'Log out?';

  @override
  String get profileLogoutMessage =>
      'You\'ll go back to the start screen. Your data stays saved while the app is open.';

  @override
  String get welcomeTitle => 'Track your diet the simple way';

  @override
  String get welcomeCreateAccount => 'Create account';

  @override
  String get welcomeGoogle => 'Continue with Google';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get welcomeHaveAccount => 'Already have an account?';

  @override
  String get welcomeLogin => 'Log in';

  @override
  String get loginTitle => 'Log in to your account';

  @override
  String get loginButton => 'Log in';
}
