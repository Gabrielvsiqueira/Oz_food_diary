import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/routes/app_routes.dart';
import '../../configs/strings/string_extensions.dart';
import '../../controllers/daily_log_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/auth_failure.dart';

/// Depois de entrar: quem já tem perfil neste aparelho vai para a Home;
/// quem ainda não tem (conta nova pelo Google, ou outro aparelho antes da
/// sincronização) responde o onboarding, sem a etapa de criar conta.
Future<void> enterAfterSignIn(BuildContext context) async {
  final hasProfile = await context.read<ProfileController>().load();
  if (!context.mounted) return;
  context.read<DailyLogController>().selectDate(DateTime.now());
  Navigator.of(context).pushNamedAndRemoveUntil(
    hasProfile ? AppRoutes.main : AppRoutes.onboardingGoal,
    (_) => false,
  );
}

void showAuthFailure(BuildContext context, AuthFailure failure) {
  final message = failure.message;
  if (message == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: AppConstants.snackBarDuration),
  );
}
