import 'dart:math';

import 'package:flutter/material.dart';

import '../../configs/theme/app_colors.dart';

class RainbowArc {
  const RainbowArc({required this.progress, required this.color});

  /// 0..1 (valores acima de 1 são limitados a um arco completo).
  final double progress;
  final Color color;
}

/// Arcos concêntricos em semicírculo: calorias por fora, depois proteínas,
/// carboidratos e gorduras (ordem do Figma).
class MacroRainbowChart extends StatelessWidget {
  const MacroRainbowChart({
    super.key,
    required this.arcs,
    required this.center,
    this.strokeWidth = 12,
    this.gap = 6,
    this.showTrack = true,
    this.semanticsLabel,
  });

  final List<RainbowArc> arcs;
  final Widget center;
  final double strokeWidth;
  final double gap;
  final bool showTrack;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width / 2 + strokeWidth / 2;
        return Semantics(
          label: semanticsLabel,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RainbowPainter(
                      arcs: arcs,
                      strokeWidth: strokeWidth,
                      gap: gap,
                      showTrack: showTrack,
                    ),
                  ),
                ),
                Align(alignment: Alignment.bottomCenter, child: center),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RainbowPainter extends CustomPainter {
  _RainbowPainter({
    required this.arcs,
    required this.strokeWidth,
    required this.gap,
    required this.showTrack,
  });

  final List<RainbowArc> arcs;
  final double strokeWidth;
  final double gap;
  final bool showTrack;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - strokeWidth / 2);
    final outerRadius = size.width / 2 - strokeWidth / 2;

    for (var i = 0; i < arcs.length; i++) {
      final radius = outerRadius - i * (strokeWidth + gap);
      if (radius <= 0) break;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (showTrack) {
        canvas.drawArc(
          rect,
          pi,
          pi,
          false,
          paint..color = AppColors.surfaceVariant,
        );
      }

      final progress = arcs[i].progress.clamp(0.0, 1.0);
      if (progress > 0) {
        canvas.drawArc(
          rect,
          pi,
          pi * progress,
          false,
          paint..color = arcs[i].color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RainbowPainter old) =>
      old.arcs != arcs ||
      old.strokeWidth != strokeWidth ||
      old.gap != gap ||
      old.showTrack != showTrack;
}
