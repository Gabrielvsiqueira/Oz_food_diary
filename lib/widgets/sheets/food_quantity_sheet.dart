import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../models/food.dart';
import '../../models/food_portion.dart';
import '../../models/meal_item.dart';
import '../../services/validators.dart';
import '../buttons/primary_button.dart';
import '../charts/nutrients_summary.dart';
import '../inputs/app_text_field.dart';
import '../layout/emoji_box.dart';

/// Pede quantidade e medida de [food]. Com [initial], edita um item já
/// adicionado. Retorna o [MealItem] confirmado ou `null` se fechado.
Future<MealItem?> showFoodQuantitySheet(
  BuildContext context, {
  required Food food,
  MealItem? initial,
}) => showModalBottomSheet<MealItem>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: AppColors.surface,
  builder: (_) => _FoodQuantitySheet(food: food, initial: initial),
);

class _FoodQuantitySheet extends StatefulWidget {
  const _FoodQuantitySheet({required this.food, this.initial});

  final Food food;
  final MealItem? initial;

  @override
  State<_FoodQuantitySheet> createState() => _FoodQuantitySheetState();
}

class _FoodQuantitySheetState extends State<_FoodQuantitySheet> {
  final _formKey = GlobalKey<FormState>();
  late FoodPortion _portion;
  late final TextEditingController _quantity;

  @override
  void initState() {
    super.initState();
    _portion = widget.initial?.portion ?? widget.food.defaultPortion;
    final quantity =
        widget.initial?.quantity ?? (_portion == FoodPortion.gram ? 100 : 1);
    _quantity = TextEditingController(
      text: formatEditableNumber(quantity),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  ValidationError? _validate(String? value) =>
      Validators.foodQuantity(value, _portion.grams);

  MealItem? get _item {
    if (_validate(_quantity.text) != null) return null;
    return MealItem(
      food: widget.food,
      portion: _portion,
      quantity: Validators.parseDecimal(_quantity.text)!,
    );
  }

  /// Mantém a mesma quantidade em gramas ao trocar de medida.
  void _changePortion(FoodPortion portion) {
    final grams = _item?.grams;
    setState(() => _portion = portion);
    if (grams != null) {
      _quantity.text = formatEditableNumber(grams / portion.grams);
    }
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_item);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final food = widget.food;
    final item = _item;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  EmojiBox(emoji: food.emoji, size: 48),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name, style: textTheme.titleMedium),
                        Text(
                          AppStrings.foodPer100g(
                            formatNumber(food.kcalPer100g),
                          ),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: AppStrings.foodQuantityLabel,
                      controller: _quantity,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      textInputAction: TextInputAction.done,
                      validator: fieldValidator(_validate),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.foodPortionLabel,
                          style: textTheme.labelLarge,
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        DropdownButtonFormField<FoodPortion>(
                          initialValue: _portion,
                          isExpanded: true,
                          items: [
                            for (final portion in food.portions)
                              DropdownMenuItem(
                                value: portion,
                                child: Text(
                                  portion.optionLabel,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (portion) {
                            if (portion != null) _changePortion(portion);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),
              NutrientsSummary(items: item == null ? null : [item]),
              const SizedBox(height: AppConstants.spacingXl),
              PrimaryButton(
                label: widget.initial == null ? AppStrings.foodAdd : AppStrings.foodUpdate,
                onPressed: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
