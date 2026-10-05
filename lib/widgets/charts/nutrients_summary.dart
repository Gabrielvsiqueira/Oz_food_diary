import 'package:flutter/material.dart';

import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../models/meal_item.dart';
import 'macro_summary_row.dart';

/// Linha "kcal · proteínas · carboidratos · gorduras" de um conjunto de
/// alimentos. Sem [items] válidos, mostra "—".
class NutrientsSummary extends StatelessWidget {
  const NutrientsSummary({super.key, required this.items});

  final List<MealItem>? items;

  @override
  Widget build(BuildContext context) {
    final items = this.items;

    String total(double Function(MealItem) value, {String suffix = ''}) {
      if (items == null) return '—';
      final sum = items.fold(0.0, (acc, i) => acc + value(i));
      return '${formatNumber(sum)}$suffix';
    }

    return MacroSummaryRow(
      items: [
        MacroSummaryItem(
          label: AppStrings.kcal,
          value: total((i) => i.calories),
          color: AppColors.calories,
        ),
        MacroSummaryItem(
          label: AppStrings.protein,
          value: total((i) => i.proteinG, suffix: AppStrings.unitGrams),
          color: AppColors.protein,
        ),
        MacroSummaryItem(
          label: AppStrings.carbs,
          value: total((i) => i.carbsG, suffix: AppStrings.unitGrams),
          color: AppColors.carbs,
        ),
        MacroSummaryItem(
          label: AppStrings.fat,
          value: total((i) => i.fatG, suffix: AppStrings.unitGrams),
          color: AppColors.fat,
        ),
      ],
    );
  }
}
