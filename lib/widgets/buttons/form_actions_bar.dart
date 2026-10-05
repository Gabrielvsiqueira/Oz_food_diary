import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
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
                  label: AppStrings.commonCancel,
                  variant: PrimaryButtonVariant.secondary,
                  onPressed: onCancel,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: PrimaryButton(label: AppStrings.commonSave, onPressed: onSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
