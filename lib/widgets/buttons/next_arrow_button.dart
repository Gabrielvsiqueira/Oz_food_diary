import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/theme/app_colors.dart';

/// Botão quadrado com seta usado para avançar no onboarding.
class NextArrowButton extends StatelessWidget {
  const NextArrowButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppConstants.buttonHeight,
      child: IconButton.filled(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward_rounded),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.25),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
        ),
      ),
    );
  }
}
