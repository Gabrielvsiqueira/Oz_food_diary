import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/theme/app_colors.dart';

/// Campo numérico com a unidade (kcal, g, cm, kg) numa caixa ao lado.
class UnitTextField extends StatelessWidget {
  const UnitTextField({
    super.key,
    required this.label,
    required this.unit,
    required this.controller,
    this.hint,
    this.validator,
    this.allowDecimal = true,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.helperText,
  });

  final String label;
  final String unit;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool allowDecimal;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelLarge),
        const SizedBox(height: AppConstants.spacingSm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                validator: validator,
                onChanged: onChanged,
                onFieldSubmitted: onSubmitted == null
                    ? null
                    : (_) => onSubmitted!(),
                textInputAction: textInputAction,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: allowDecimal,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    allowDecimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]'),
                  ),
                ],
                decoration: InputDecoration(
                  hintText: hint,
                  helperText: helperText,
                  helperMaxLines: 2,
                  errorMaxLines: 2,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Container(
              height: 52,
              constraints: const BoxConstraints(minWidth: 56),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              ),
              child: Text(
                unit,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
