import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../configs/constants/app_constants.dart';

/// Campo com rótulo acima, como no Figma.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.suffixIcon,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? helperText;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppConstants.spacingSm),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            helperText: helperText,
            helperMaxLines: 2,
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
