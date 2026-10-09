import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'configs/routes/app_routes.dart';
import 'configs/routes/route_generator.dart';
import 'configs/theme/app_theme.dart';
import 'controllers/daily_log_controller.dart';
import 'controllers/meal_controller.dart';
import 'controllers/onboarding_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/session_controller.dart';
import 'database/app_database.dart';
import 'repositories/drift_food_repository.dart';
import 'repositories/drift_meal_repository.dart';
import 'repositories/drift_profile_repository.dart';
import 'repositories/food_repository.dart';
import 'repositories/local_session_repository.dart';
import 'repositories/meal_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/session_repository.dart';

class OzApp extends StatelessWidget {
  const OzApp({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FoodRepository>(create: (_) => DriftFoodRepository(database)),
        Provider<MealRepository>(create: (_) => DriftMealRepository(database)),
        Provider<ProfileRepository>(
          create: (_) => DriftProfileRepository(database),
        ),
        Provider<SessionRepository>(
          create: (context) => LocalSessionRepository(
            database,
            profiles: context.read(),
            meals: context.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SessionController(context.read()),
        ),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(
          create: (context) => ProfileController(context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => DailyLogController(context.read()),
        ),
        ChangeNotifierProxyProvider<DailyLogController, MealController>(
          create: (context) => MealController(
            context.read(),
            context.read<DailyLogController>(),
          ),
          update: (_, dailyLog, meal) => meal!..updateDailyLog(dailyLog),
        ),
      ],
      child: MaterialApp(
        title: 'Oz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generate,
      ),
    );
  }
}
