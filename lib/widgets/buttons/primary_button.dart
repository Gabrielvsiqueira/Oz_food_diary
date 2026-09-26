import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/theme/app_colors.dart';

enum PrimaryButtonVariant { primary, secondary }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PrimaryButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final PrimaryButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == PrimaryButtonVariant.primary;
    final background = isPrimary ? AppColors.primary : AppColors.surfaceVariant;
    final foreground = isPrimary ? AppColors.onPrimary : AppColors.onSurface;

    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.3),
          disabledForegroundColor: foreground.withValues(alpha: 0.5),
          textStyle: Theme.of(context).textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
