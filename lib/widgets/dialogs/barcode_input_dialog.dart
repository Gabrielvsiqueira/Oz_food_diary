import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../services/validators.dart';

/// Pede o código de barras digitado (câmera sem permissão, código
/// danificado, emulador sem câmera). Retorna o código ou `null`.
Future<String?> showBarcodeInputDialog(BuildContext context) =>
    showDialog<String>(
      context: context,
      builder: (_) => const _BarcodeInputDialog(),
    );

class _BarcodeInputDialog extends StatefulWidget {
  const _BarcodeInputDialog();

  @override
  State<_BarcodeInputDialog> createState() => _BarcodeInputDialogState();
}

class _BarcodeInputDialogState extends State<_BarcodeInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_code.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.barcodeLabel),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _code,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.search,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(14),
          ],
          validator: fieldValidator(Validators.barcode),
          onFieldSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            hintText: '7891000100103',
            errorMaxLines: 2,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.onSurfaceSecondary,
          ),
          child: Text(AppStrings.commonCancel),
        ),
        TextButton(
          onPressed: _submit,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: Text(AppStrings.barcodeSearch),
        ),
      ],
    );
  }
}
