import 'package:flutter/material.dart';

import '../../configs/l10n/l10n_extensions.dart';
import '../../services/validators.dart';
import '../../widgets/inputs/unit_text_field.dart';

/// Corpo compartilhado pelas telas de altura e peso: um único campo com
/// unidade, centralizado verticalmente.
class OnboardingMeasureBody extends StatelessWidget {
  const OnboardingMeasureBody({
    super.key,
    required this.formKey,
    required this.controller,
    required this.label,
    required this.unit,
    required this.hint,
    required this.validator,
    required this.onChanged,
    required this.onSubmitted,
    this.allowDecimal = true,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String label;
  final String unit;
  final String hint;
  final ValidationError? Function(String?) validator;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Center(
        child: UnitTextField(
          label: label,
          unit: unit,
          hint: hint,
          controller: controller,
          allowDecimal: allowDecimal,
          textInputAction: TextInputAction.done,
          validator: localizedValidator(context, validator),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
