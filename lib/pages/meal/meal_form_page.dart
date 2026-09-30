import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/l10n/l10n_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/meal_controller.dart';
import '../../models/enums/meal_type.dart';
import '../../models/meal.dart';
import '../../services/validators.dart';
import '../../widgets/buttons/form_actions_bar.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/unit_text_field.dart';

class MealFormPage extends StatefulWidget {
  const MealFormPage({super.key, this.meal});

  final Meal? meal;

  @override
  State<MealFormPage> createState() => _MealFormPageState();
}

class _MealFormPageState extends State<MealFormPage> {
  final _formKey = GlobalKey<FormState>();
  late MealType _type;
  late final TextEditingController _description;
  late final TextEditingController _carbs;
  late final TextEditingController _protein;
  late final TextEditingController _fat;
  ValidationError? _macrosError;

  bool get _isEditing => widget.meal != null;

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;
    String number(num? value) =>
        value == null ? '' : formatEditableNumber(value, 'en');
    _type = meal?.type ?? _suggestedType(DateTime.now());
    _description = TextEditingController(text: meal?.description ?? '');
    _carbs = TextEditingController(text: number(meal?.carbsG));
    _protein = TextEditingController(text: number(meal?.proteinG));
    _fat = TextEditingController(text: number(meal?.fatG));
    for (final c in [_carbs, _protein, _fat]) {
      c.addListener(_onNumbersChanged);
    }
  }

  @override
  void dispose() {
    for (final c in [_description, _carbs, _protein, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  static MealType _suggestedType(DateTime now) => switch (now.hour) {
    >= 5 && < 11 => MealType.breakfast,
    >= 11 && < 15 => MealType.lunch,
    >= 18 && < 23 => MealType.dinner,
    _ => MealType.snack,
  };

  double? _parse(TextEditingController c) => Validators.parseDecimal(c.text);

  void _onNumbersChanged() => setState(() => _macrosError = null);

  int? get _calories {
    final carbs = _parse(_carbs);
    final protein = _parse(_protein);
    final fat = _parse(_fat);
    if (carbs == null || protein == null || fat == null) return null;
    return context.read<MealController>().caloriesFromMacros(
      carbsG: carbs,
      proteinG: protein,
      fatG: fat,
    );
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<MealController>();
    final carbs = _parse(_carbs)!;
    final protein = _parse(_protein)!;
    final fat = _parse(_fat)!;

    final error = controller.validateMacros(
      carbsG: carbs,
      proteinG: protein,
      fatG: fat,
    );
    if (error != null) {
      setState(() => _macrosError = error);
      return;
    }

    if (_isEditing) {
      controller.updateMeal(
        widget.meal!.copyWith(
          type: _type,
          description: _description.text.trim(),
          carbsG: carbs,
          proteinG: protein,
          fatG: fat,
        ),
      );
    } else {
      controller.addMeal(
        type: _type,
        description: _description.text,
        carbsG: carbs,
        proteinG: protein,
        fatG: fat,
      );
    }
    _closeWithMessage(context.l10n.mealSaved);
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.mealDeleteTitle,
      message: l10n.mealDeleteMessage,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    context.read<MealController>().deleteMeal(widget.meal!);
    _closeWithMessage(l10n.mealDeleted);
  }

  void _closeWithMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text(message), duration: AppConstants.snackBarDuration),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.mealEditTitle : l10n.mealNewTitle),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l10n.commonDelete,
              onPressed: _delete,
              color: AppColors.error,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          children: [
            Text(l10n.mealTypeLabel, style: textTheme.labelLarge),
            const SizedBox(height: AppConstants.spacingSm),
            Wrap(
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              children: [
                for (final type in MealType.values)
                  ChoiceChip(
                    avatar: Text(type.emoji),
                    label: Text(type.label(l10n)),
                    selected: _type == type,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _type = type),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: _type == type
                          ? AppColors.primary
                          : AppColors.onSurface,
                    ),
                    side: BorderSide(
                      color: _type == type
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLg),
            AppTextField(
              label: l10n.mealDescriptionLabel,
              hint: l10n.mealDescriptionHint,
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              validator: localizedValidator(context, Validators.required),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: l10n.carbs,
              unit: l10n.unitGrams,
              controller: _carbs,
              validator: localizedValidator(
                context,
                Validators.nonNegativeNumber,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: l10n.protein,
              unit: l10n.unitGrams,
              controller: _protein,
              validator: localizedValidator(
                context,
                Validators.nonNegativeNumber,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: l10n.fat,
              unit: l10n.unitGrams,
              controller: _fat,
              textInputAction: TextInputAction.done,
              onSubmitted: _save,
              validator: localizedValidator(
                context,
                Validators.nonNegativeNumber,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            _CaloriesSummary(calories: _calories),
            if (_macrosError != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                _macrosError!.message(l10n),
                style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ],
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

/// Calorias da refeição, somente leitura: sempre calculadas pelos macros.
class _CaloriesSummary extends StatelessWidget {
  const _CaloriesSummary({required this.calories});

  final int? calories;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final value = calories == null
        ? '—'
        : formatNumber(calories!, context.localeName);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.calories, style: textTheme.labelLarge),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  l10n.mealCaloriesAuto,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Text(
            '$value ${l10n.unitKcal}',
            style: textTheme.titleLarge?.copyWith(color: AppColors.calories),
          ),
        ],
      ),
    );
  }
}
