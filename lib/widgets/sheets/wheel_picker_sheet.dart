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
  builder: (context) {
    var value = initial;
    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppConstants.spacingLg),
            builder(value, (v) => setState(() => value = v)),
            const SizedBox(height: AppConstants.spacingXl),
            PrimaryButton(
              label: AppStrings.commonConfirm,
              onPressed: () => Navigator.of(context).pop(value),
            ),
          ],
        ),
      ),
    );
  },
);
