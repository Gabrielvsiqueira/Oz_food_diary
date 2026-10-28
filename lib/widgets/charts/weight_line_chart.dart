import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../models/weight_entry.dart';

/// Linha do peso ao longo do tempo. O eixo X é em dias desde a primeira
/// medição, para que dias sem medição fiquem com o espaço certo.
class WeightLineChart extends StatelessWidget {
  const WeightLineChart({super.key, required this.entries})
    : assert(entries.length >= 2);

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.bodySmall?.copyWith(
      color: AppColors.onSurfaceSecondary,
    );
    final dayFormat = DateFormat('dd/MM', appLocale);

    final first = entries.first.date;
    double dayOf(DateTime date) => date.difference(first).inDays.toDouble();
    final lastDay = dayOf(entries.last.date);
    final weights = entries.map((e) => e.weightKg);
    // Margem de 1 kg para a linha não encostar nas bordas.
    final minY = (weights.reduce(min) - 1).floorToDouble();
    final maxY = (weights.reduce(max) + 1).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: max(lastDay, 1),
        minY: minY,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: _niceInterval(maxY - minY),
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: _niceInterval(maxY - minY),
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(formatEditableNumber(value), style: labelStyle),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              // Três datas no máximo: início, meio e fim.
              interval: max(lastDay / 2, 1),
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  dayFormat.format(first.add(Duration(days: value.round()))),
                  style: labelStyle,
                ),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceVariant,
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  '${formatEditableNumber(spot.y)} ${AppStrings.unitKg}\n',
                  textTheme.titleSmall!.copyWith(color: AppColors.onSurface),
                  children: [
                    TextSpan(
                      text: dayFormat.format(entries[spot.spotIndex].date),
                      style: labelStyle,
                    ),
                  ],
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (final entry in entries)
                FlSpot(dayOf(entry.date), entry.weightKg),
            ],
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 3,
            // Com muitas medições, os pontos poluem a linha.
            dotData: FlDotData(show: entries.length <= 31),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 1, 2 ou 5 kg entre as linhas, para ter de 3 a 5 linhas.
  static double _niceInterval(double range) => switch (range) {
    <= 5 => 1,
    <= 10 => 2,
    <= 25 => 5,
    _ => 10,
  };
}
