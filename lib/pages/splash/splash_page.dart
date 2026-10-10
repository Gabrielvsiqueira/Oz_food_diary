import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/branding/oz_background.dart';
import '../../widgets/branding/oz_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  /// Quem já entrou neste aparelho vai direto para a Home, mesmo offline.
  /// Com sessão mas sem perfil salvo aqui, completa o onboarding.
  Future<void> _start() async {
    final session = context.read<SessionController>();
    final profile = context.read<ProfileController>();
    final (route, _) = await (
      session.restore().then((signedIn) async {
        if (!signedIn) return AppRoutes.welcome;
        return await profile.load() ? AppRoutes.main : AppRoutes.onboardingGoal;
      }),
      Future<void>.delayed(AppConstants.splashDuration),
    ).wait;
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Stack(
        fit: StackFit.expand,
        children: [
          OzBackground(),
          Center(child: OzLogo()),
        ],
      ),
    );
  }
}
