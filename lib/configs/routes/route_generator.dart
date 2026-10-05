import 'package:flutter/material.dart';

import '../../models/meal.dart';
import '../../pages/food_search/food_search_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/main_shell/main_shell_page.dart';
import '../../pages/meal/meal_form_page.dart';
import '../../pages/onboarding/onboarding_account_page.dart';
import '../../pages/onboarding/onboarding_activity_page.dart';
import '../../pages/onboarding/onboarding_birthdate_page.dart';
import '../../pages/onboarding/onboarding_gender_page.dart';
import '../../pages/onboarding/onboarding_goal_page.dart';
import '../../pages/onboarding/onboarding_height_page.dart';
import '../../pages/onboarding/onboarding_loading_page.dart';
import '../../pages/onboarding/onboarding_result_page.dart';
import '../../pages/onboarding/onboarding_weight_page.dart';
import '../../pages/splash/splash_page.dart';
import '../../pages/welcome/welcome_page.dart';
import 'app_routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generate(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.splash => const SplashPage(),
      AppRoutes.welcome => const WelcomePage(),
      AppRoutes.login => const LoginPage(),
      AppRoutes.onboardingGoal => const OnboardingGoalPage(),
      AppRoutes.onboardingGender => const OnboardingGenderPage(),
      AppRoutes.onboardingBirthdate => const OnboardingBirthdatePage(),
      AppRoutes.onboardingHeight => const OnboardingHeightPage(),
      AppRoutes.onboardingWeight => const OnboardingWeightPage(),
      AppRoutes.onboardingActivity => const OnboardingActivityPage(),
      AppRoutes.onboardingAccount => const OnboardingAccountPage(),
      AppRoutes.onboardingLoading => const OnboardingLoadingPage(),
      AppRoutes.onboardingResult => const OnboardingResultPage(),
      AppRoutes.main => const MainShellPage(),
      AppRoutes.mealForm => MealFormPage(meal: settings.arguments as Meal?),
      AppRoutes.foodSearch => const FoodSearchPage(),
      _ => const SplashPage(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
