import 'package:flutter/material.dart';

import '../../configs/theme/app_colors.dart';

class MacroSummaryItem {
  const MacroSummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.target,
  });

  final String label;

  /// Valor principal, colorido (ex.: "74" ou "175g").
  final String value;

  /// Meta opcional, em cinza (ex.: "175g" → "74 / 175g").
  final String? target;
  final Color color;
}

/// Linha "74 / 175g Proteínas · 70 / 200g Carboidratos · 8 / 56g Gorduras".
class MacroSummaryRow extends StatelessWidget {
  const MacroSummaryRow({super.key, required this.items});

  final List<MacroSummaryItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: item.value,
                          style: TextStyle(color: item.color),
                        ),
                        if (item.target != null)
                          TextSpan(
                            text: ' / ${item.target}',
                            style: const TextStyle(
                              color: AppColors.onSurfaceSecondary,
                            ),
                          ),
                      ],
                    ),
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
