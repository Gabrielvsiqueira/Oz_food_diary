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
  Future<void> _start() async {
    final session = context.read<SessionController>();
    final profile = context.read<ProfileController>();
    final (signedIn, _) = await (
      session.restore().then((ok) async => ok && await profile.load()),
      Future<void>.delayed(AppConstants.splashDuration),
    ).wait;
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacementNamed(signedIn ? AppRoutes.main : AppRoutes.welcome);
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
