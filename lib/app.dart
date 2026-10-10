import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'configs/constants/app_constants.dart';
import 'configs/env.dart';
import 'configs/routes/app_routes.dart';
import 'configs/routes/route_generator.dart';
import 'configs/strings/app_strings.dart';
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
import 'repositories/supabase_session_repository.dart';

class OzApp extends StatefulWidget {
  const OzApp({super.key, required this.database, this.supabase});

  final AppDatabase database;

  /// Sem cliente (Supabase não configurado), usa a sessão local.
  final SupabaseClient? supabase;

  @override
  State<OzApp> createState() => _OzAppState();
}

class _OzAppState extends State<OzApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  AppDatabase get database => widget.database;

  SessionRepository _sessionRepository(BuildContext context) {
    final supabase = widget.supabase;
    if (supabase == null) {
      return LocalSessionRepository(
        database,
        profiles: context.read(),
        meals: context.read(),
      );
    }
    return SupabaseSessionRepository(
      supabase,
      database,
      googleWebClientId: Env.googleWebClientId,
      googleIosClientId: Env.googleIosClientId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FoodRepository>(create: (_) => DriftFoodRepository(database)),
        Provider<MealRepository>(create: (_) => DriftMealRepository(database)),
        Provider<ProfileRepository>(
          create: (_) => DriftProfileRepository(database),
        ),
        Provider<SessionRepository>(create: _sessionRepository),
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
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _messengerKey,
        builder: (context, child) => _RevokedSessionListener(
          navigatorKey: _navigatorKey,
          messengerKey: _messengerKey,
          child: child!,
        ),
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

/// Quando o servidor encerra a sessão (senha trocada, conta excluída em
/// outro aparelho), volta para o início e avisa o usuário.
class _RevokedSessionListener extends StatefulWidget {
  const _RevokedSessionListener({
    required this.navigatorKey,
    required this.messengerKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  State<_RevokedSessionListener> createState() =>
      _RevokedSessionListenerState();
}

class _RevokedSessionListenerState extends State<_RevokedSessionListener> {
  late final SessionController _session;

  @override
  void initState() {
    super.initState();
    _session = context.read<SessionController>()..addListener(_onChange);
  }

  void _onChange() {
    if (!_session.wasRevoked || _session.isAuthenticated) return;
    widget.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.welcome,
      (_) => false,
    );
    widget.messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(AppStrings.authSessionRevoked),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  @override
  void dispose() {
    _session.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
