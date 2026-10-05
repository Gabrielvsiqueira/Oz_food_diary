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
import 'repositories/food_repository.dart';
import 'repositories/mock_food_repository.dart';

class OzApp extends StatelessWidget {
  const OzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FoodRepository>(create: (_) => const MockFoodRepository()),
        ChangeNotifierProvider(create: (_) => SessionController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => DailyLogController()),
        ChangeNotifierProxyProvider<DailyLogController, MealController>(
          create: (context) =>
              MealController(context.read<DailyLogController>()),
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
