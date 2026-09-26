import 'dart:async';

import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/routes/app_routes.dart';
import '../../widgets/branding/oz_background.dart';
import '../../widgets/branding/oz_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppConstants.splashDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
