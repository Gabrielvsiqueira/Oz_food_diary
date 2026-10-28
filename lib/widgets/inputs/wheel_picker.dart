import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/constants/nutrition_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';

/// Roleta de números inteiros (idade, altura) com a unidade ao lado. Só
/// oferece valores entre [min] e [max], então não precisa de validação.
class IntWheelPicker extends StatelessWidget {
  const IntWheelPicker({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    required this.unit,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return _WheelFrame(
      unit: unit,
      wheels: [
        _Wheel(
          count: max - min + 1,
          index: value.clamp(min, max) - min,
          width: 96,
          label: (i) => '${min + i}',
          onChanged: (i) => onChanged(min + i),
        ),
      ],
    );
  }
}

/// Peso em duas roletas, como em balanças digitais: kg inteiros e a casa
/// decimal (,0 a ,9).
class WeightWheelPicker extends StatelessWidget {
  const WeightWheelPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _min = NutritionConstants.minWeightKg;
  static const _max = NutritionConstants.maxWeightKg;

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final tenths = (value.clamp(_min, _max) * 10).round();
    final kg = tenths ~/ 10;
    final decimal = tenths % 10;
    final minKg = _min.toInt();

    // No peso máximo, só ",0" é válido; a roleta decimal volta para 0.
    void emit(int kg, int decimal) =>
        onChanged(((kg * 10 + decimal).clamp(_min * 10, _max * 10)) / 10);

    return _WheelFrame(
      unit: AppStrings.unitKg,
      wheels: [
        _Wheel(
          count: _max.toInt() - minKg + 1,
          index: kg - minKg,
          width: 88,
          label: (i) => '${minKg + i}',
          onChanged: (i) => emit(minKg + i, decimal),
        ),
        _Wheel(
          count: 10,
          index: decimal,
          width: 56,
          label: (i) => ',$i',
          onChanged: (i) => emit(kg, i),
        ),
      ],
    );
  }
}

/// Faixa de seleção atrás das roletas e a unidade na mesma linha do valor
/// escolhido.
class _WheelFrame extends StatelessWidget {
  const _WheelFrame({required this.wheels, required this.unit});

  static const visibleItems = 5;

  final List<Widget> wheels;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _Wheel.itemExtent * visibleItems,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: _Wheel.itemExtent,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...wheels,
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                unit,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurfaceSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Wheel extends StatefulWidget {
  const _Wheel({
    required this.count,
    required this.index,
    required this.width,
    required this.label,
    required this.onChanged,
  });

  static const itemExtent = 48.0;

  final int count;
  final int index;
  final double width;
  final String Function(int index) label;
  final ValueChanged<int> onChanged;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final _controller = FixedExtentScrollController(
    initialItem: widget.index,
  );

  /// Último item em que a roleta parou; evita brigar com o dedo do usuário.
  late int _selected = widget.index;

  @override
  void didUpdateWidget(_Wheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Valor mudou por fora (ex.: o peso máximo zerou o decimal).
    if (widget.index != _selected && _controller.hasClients) {
      _selected = widget.index;
      _controller.jumpToItem(widget.index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSelected(int index) {
    _selected = index;
    // O CupertinoPicker já vibra no iOS; nas outras plataformas, vibra aqui.
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      HapticFeedback.selectionClick();
    }
    widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineSmall;
    return SizedBox(
      width: widget.width,
      child: CupertinoPicker.builder(
        scrollController: _controller,
        itemExtent: _Wheel.itemExtent,
        childCount: widget.count,
        diameterRatio: 1.3,
        squeeze: 1.1,
        useMagnifier: true,
        magnification: 1.15,
        backgroundColor: Colors.transparent,
        // A faixa é desenhada uma vez só, atrás de todas as roletas.
        selectionOverlay: const SizedBox.shrink(),
        onSelectedItemChanged: _onSelected,
        itemBuilder: (context, index) =>
            Center(child: Text(widget.label(index), style: style)),
      ),
    );
  }
}
