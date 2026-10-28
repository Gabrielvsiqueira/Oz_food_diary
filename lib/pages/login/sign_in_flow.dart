import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/routes/app_routes.dart';
import '../../configs/strings/string_extensions.dart';
import '../../controllers/daily_log_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../models/auth_failure.dart';

/// Depois de entrar: baixa os dados da conta e vai para a Home; quem ainda
/// não tem perfil (conta nova pelo Google) responde o onboarding, sem a
/// etapa de criar conta.
Future<void> enterAfterSignIn(BuildContext context) async {
  final sync = context.read<SyncController>();
  final profile = context.read<ProfileController>();
  final synced = await sync.syncNow();
  final hasProfile = await profile.load();
  if (!context.mounted) return;
  if (!hasProfile && !synced) {
    // Sem os dados da conta, o onboarding criaria um perfil por cima do
    // que já existe no servidor.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.syncErrorFirstDownload),
        duration: AppConstants.snackBarDuration,
      ),
    );
    return;
  }
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
