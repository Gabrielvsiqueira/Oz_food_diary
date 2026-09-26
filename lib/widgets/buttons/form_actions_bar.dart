import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/l10n/l10n_extensions.dart';
import '../../configs/theme/app_colors.dart';
import 'primary_button.dart';

/// Rodapé "Cancelar / Salvar" dos formulários (Metas, refeição).
class FormActionsBar extends StatelessWidget {
  const FormActionsBar({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: l10n.commonCancel,
                  variant: PrimaryButtonVariant.secondary,
                  onPressed: onCancel,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: PrimaryButton(label: l10n.commonSave, onPressed: onSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
