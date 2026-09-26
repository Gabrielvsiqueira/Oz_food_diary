import 'package:flutter/material.dart';

import '../../configs/l10n/l10n_extensions.dart';
import '../../configs/theme/app_colors.dart';

/// Mostra um alerta de confirmação e retorna `true` se o usuário confirmou.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.onSurfaceSecondary,
          ),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: destructive ? AppColors.error : AppColors.primary,
          ),
          child: Text(confirmLabel ?? l10n.commonConfirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
