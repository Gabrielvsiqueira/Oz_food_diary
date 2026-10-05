class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const onboardingGoal = '/onboarding/goal';
  static const onboardingGender = '/onboarding/gender';
  static const onboardingBirthdate = '/onboarding/birthdate';
  static const onboardingHeight = '/onboarding/height';
  static const onboardingWeight = '/onboarding/weight';
  static const onboardingActivity = '/onboarding/activity';
  static const onboardingAccount = '/onboarding/account';
  static const onboardingLoading = '/onboarding/loading';
  static const onboardingResult = '/onboarding/result';

  /// Shell com bottom navigation (Home / Metas / Perfil).
  static const main = '/main';

  /// Argumento opcional: `Meal` para edição.
  static const mealForm = '/meal/form';

  /// Retorna o `MealItem` escolhido ao fechar.
  static const foodSearch = '/meal/food-search';
}
