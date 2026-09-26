import 'package:flutter/material.dart';

import '../../configs/theme/app_typography.dart';
import '../../configs/theme/app_colors.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
    this.onLabelTap,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onLabelTap;
  final String previousTooltip;
  final String nextTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          tooltip: previousTooltip,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: InkWell(
            onTap: onLabelTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          tooltip: nextTooltip,
          disabledColor: AppColors.surfaceVariant,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
