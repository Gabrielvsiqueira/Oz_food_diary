import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/theme/app_colors.dart';

/// Superfície com borda/realce lime quando selecionada.
class SelectableSurface extends StatelessWidget {
  const SelectableSurface({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.spacingMd),
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.radiusXxl);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
