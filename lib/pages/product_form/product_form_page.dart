import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../models/product_info.dart';
import '../../services/validators.dart';
import '../../widgets/buttons/form_actions_bar.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/unit_text_field.dart';

/// Completa um produto lido pelo código de barras (ou cadastra um que a
/// Open Food Facts não conhece). Fecha retornando o [ProductInfo] completo.
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, required this.product});

  final ProductInfo product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product.name);
  late final _kcal = _numberController(widget.product.kcalPer100g);
  late final _carbs = _numberController(widget.product.carbsPer100g);
  late final _protein = _numberController(widget.product.proteinPer100g);
  late final _fat = _numberController(widget.product.fatPer100g);
  late final _serving = _numberController(widget.product.servingGrams);

  static TextEditingController _numberController(double? value) =>
      TextEditingController(
        text: value == null ? '' : formatEditableNumber(value),
      );

  @override
  void dispose() {
    for (final c in [_name, _kcal, _carbs, _protein, _fat, _serving]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ProductInfo(
        barcode: widget.product.barcode,
        name: _name.text.trim(),
        kcalPer100g: Validators.parseDecimal(_kcal.text),
        carbsPer100g: Validators.parseDecimal(_carbs.text),
        proteinPer100g: Validators.parseDecimal(_protein.text),
        fatPer100g: Validators.parseDecimal(_fat.text),
        servingGrams: Validators.parseDecimal(_serving.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.product.isEmpty;
    final nonNegative = fieldValidator(Validators.nonNegativeNumber);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNew
              ? AppStrings.productFormNewTitle
              : AppStrings.productFormCompleteTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          children: [
            Text(
              isNew
                  ? AppStrings.productFormNewHint
                  : AppStrings.productFormCompleteHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              '${AppStrings.barcodeLabel}: ${widget.product.barcode}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            AppTextField(
              label: AppStrings.productFormName,
              hint: AppStrings.productFormNameHint,
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              validator: fieldValidator(Validators.required),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: AppStrings.calories,
              unit: AppStrings.unitKcal,
              controller: _kcal,
              validator: nonNegative,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: AppStrings.carbs,
              unit: AppStrings.unitGrams,
              controller: _carbs,
              validator: nonNegative,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: AppStrings.protein,
              unit: AppStrings.unitGrams,
              controller: _protein,
              validator: nonNegative,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: AppStrings.fat,
              unit: AppStrings.unitGrams,
              controller: _fat,
              validator: nonNegative,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: AppStrings.productFormServing,
              unit: AppStrings.unitGrams,
              controller: _serving,
              helperText: AppStrings.productFormServingHelper,
              textInputAction: TextInputAction.done,
              onSubmitted: _save,
              validator: fieldValidator(Validators.servingGrams),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FormActionsBar(
        onCancel: () => Navigator.of(context).pop(),
        onSave: _save,
      ),
    );
  }
}
