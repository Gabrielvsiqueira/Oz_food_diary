import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/l10n/l10n_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../models/meal.dart';
import '../layout/emoji_box.dart';

/// Card de refeição: tipo + descrição + grade de kcal e macros.
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, required this.onTap});

  final Meal meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeName;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppConstants.radiusXxl);

    String grams(double value) =>
        '${formatNumber(value, locale)}${l10n.unitGrams}';

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingSm),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingSm),
                child: Row(
                  children: [
                    EmojiBox(emoji: meal.type.emoji, size: 48),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.type.label(l10n),
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurfaceSecondary,
                            ),
                          ),
                          Text(
                            meal.description,
                            style: textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _MacroCell(
                          value: formatNumber(meal.calories, locale),
                          label: l10n.kcal,
                          color: AppColors.calories,
                        ),
                        _MacroCell(
                          value: grams(meal.proteinG),
                          label: l10n.protein,
                          color: AppColors.protein,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Row(
                      children: [
                        _MacroCell(
                          value: grams(meal.carbsG),
                          label: l10n.carbs,
                          color: AppColors.carbs,
                        ),
                        _MacroCell(
                          value: grams(meal.fatG),
                          label: l10n.fat,
                          color: AppColors.fat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroCell extends StatelessWidget {
  const _MacroCell({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: textTheme.titleMedium?.copyWith(color: color)),
          Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
