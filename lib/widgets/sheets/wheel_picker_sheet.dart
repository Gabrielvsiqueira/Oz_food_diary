import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../buttons/primary_button.dart';

/// Folha com uma roleta ([builder]) e "Confirmar". Começa em [initial] e
/// retorna o valor escolhido, ou `null` se fechada.
Future<T?> showWheelPickerSheet<T>(
  BuildContext context, {
  required String title,
  required T initial,
  required Widget Function(T value, ValueChanged<T> onChanged) builder,
}) => showModalBottomSheet<T>(
  context: context,
  useSafeArea: true,
  backgroundColor: AppColors.surface,
  builder: (_) =>
      _WheelPickerSheet<T>(title: title, initial: initial, builder: builder),
);

/// O valor fica num [State]: o builder da folha pode rodar de novo (girar a
/// tela, mudar o tema) e não pode voltar ao valor inicial.
class _WheelPickerSheet<T> extends StatefulWidget {
  const _WheelPickerSheet({
    required this.title,
    required this.initial,
    required this.builder,
  });

  final String title;
  final T initial;
  final Widget Function(T value, ValueChanged<T> onChanged) builder;

  @override
  State<_WheelPickerSheet<T>> createState() => _WheelPickerSheetState<T>();
}

class _WheelPickerSheetState<T> extends State<_WheelPickerSheet<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppConstants.spacingLg),
          widget.builder(_value, (v) => setState(() => _value = v)),
          const SizedBox(height: AppConstants.spacingXl),
          PrimaryButton(
            label: AppStrings.commonConfirm,
            onPressed: () => Navigator.of(context).pop(_value),
          ),
        ],
      ),
    );
  }
}
