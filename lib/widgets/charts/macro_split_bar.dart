import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/app_strings.dart';
import '../../configs/theme/app_colors.dart';
import '../../models/food.dart';

/// Quanto das calorias do alimento vem de carboidrato, proteína e gordura
/// (4, 4 e 9 kcal por grama) e, nas bebidas alcoólicas, do álcool. Sai só
/// dos valores nutricionais, então não depende de adivinhar nada pelo nome.
/// Sem calorias para dividir (café, chá, refrigerante zero), não aparece.
class MacroSplitBar extends StatelessWidget {
  const MacroSplitBar({
    super.key,
    required this.food,
    this.showLegend = false,
    this.margin = EdgeInsets.zero,
  });

  final Food food;

  /// Espaço em volta da barra, que some junto com ela.
  final EdgeInsetsGeometry margin;

  /// Mostra a porcentagem de cada macro abaixo da barra.
  final bool showLegend;

  static const _height = 6.0;

  @override
  Widget build(BuildContext context) {
    final split = MacroSplit.of(food);
    if (split == null) return const SizedBox.shrink();
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(_height / 2),
      child: SizedBox(
        height: _height,
        child: Row(
          children: [
            for (final (_, share, color) in split.entries)
              if (share > 0)
                Expanded(
                  flex: (share * 1000).round().clamp(1, 1000),
                  child: ColoredBox(color: color),
                ),
          ],
        ),
      ),
    );

    return Padding(
      padding: margin,
      child: Semantics(
        label: split.description,
        excludeSemantics: true,
        child: showLegend
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  bar,
                  const SizedBox(height: AppConstants.spacingSm),
                  _Legend(split: split),
                ],
              )
            : bar,
      ),
    );
  }
}

/// Fração das calorias de cada macro e do álcool; nula quando não há
/// calorias para dividir.
class MacroSplit {
  const MacroSplit._(this.carbs, this.protein, this.fat, this.alcohol);

  /// A partir de quanto das calorias sem explicação pelos macros a sobra é
  /// tratada como álcool. Nas bebidas alcoólicas do IBGE a sobra vai de 34%
  /// a 100% das calorias e de 21,8 a 231 kcal a cada 100 g; nos demais
  /// alimentos (arredondamento, fibras), até 17%. O mínimo em kcal evita que
  /// a sobra de 1 kcal de um café vire "100% álcool".
  static const alcoholThreshold = 0.25;
  static const alcoholMinKcal = 10;

  static MacroSplit? of(Food food) {
    final carbs = food.carbsPer100g * 4;
    final protein = food.proteinPer100g * 4;
    final fat = food.fatPer100g * 9;
    final macros = carbs + protein + fat;
    final rest = food.kcalPer100g - macros;
    final alcohol =
        rest >= alcoholMinKcal && rest / food.kcalPer100g >= alcoholThreshold
        ? rest
        : 0.0;
    final total = macros + alcohol;
    if (total <= 0) return null;
    return MacroSplit._(
      carbs / total,
      protein / total,
      fat / total,
      alcohol / total,
    );
  }

  final double carbs;
  final double protein;
  final double fat;
  final double alcohol;

  /// (nome, fração, cor) de cada macro, na ordem da barra.
  List<(String, double, Color)> get entries => [
    (AppStrings.carbs, carbs, AppColors.carbs),
    (AppStrings.protein, protein, AppColors.protein),
    (AppStrings.fat, fat, AppColors.fat),
    if (alcohol > 0) (AppStrings.alcohol, alcohol, AppColors.alcohol),
  ];

  String get description => [
    for (final (label, share, _) in entries) '$label ${_percent(share)}',
  ].join(', ');
}

String _percent(double share) => '${(share * 100).round()}%';

class _Legend extends StatelessWidget {
  const _Legend({required this.split});

  final MacroSplit split;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceSecondary);
    return Wrap(
      spacing: AppConstants.spacingMd,
      children: [
        for (final (label, share, color) in split.entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppConstants.spacingXs),
              Text('$label ${_percent(share)}', style: style),
            ],
          ),
      ],
    );
  }
}
