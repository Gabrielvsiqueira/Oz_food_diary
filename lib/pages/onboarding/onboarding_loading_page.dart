import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/session_controller.dart';

/// Calcula as metas a partir das respostas do onboarding e segue para o
/// resultado depois de uma pequena espera (feedback visual).
class OnboardingLoadingPage extends StatefulWidget {
  const OnboardingLoadingPage({super.key});

  @override
  State<OnboardingLoadingPage> createState() => _OnboardingLoadingPageState();
}

class _OnboardingLoadingPageState extends State<OnboardingLoadingPage> {
  @override
  void initState() {
    super.initState();
    // Depois do primeiro frame: notificar controllers durante o build
    // dispararia rebuilds de outras telas no meio da construção desta.
    WidgetsBinding.instance.addPostFrameCallback((_) => _personalize());
  }

  Future<void> _personalize() async {
    final onboarding = context.read<OnboardingController>();
    final profile = onboarding.buildProfile();
    final session = context.read<SessionController>();
    await (
      context.read<ProfileController>().completeOnboarding(profile),
      Future<void>.delayed(AppConstants.onboardingLoadingDuration),
    ).wait;
    session.startSession();
    onboarding.reset();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox.square(
                  dimension: 48,
                  child: CircularProgressIndicator(strokeWidth: 4),
                ),
                const SizedBox(height: AppConstants.spacingXl),
                Text(
                  AppStrings.onboardingLoadingTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
