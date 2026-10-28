import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/meal_controller.dart';
import '../../models/enums/meal_type.dart';
import '../../models/meal.dart';
import '../../models/meal_item.dart';
import '../../services/validators.dart';
import '../../widgets/buttons/form_actions_bar.dart';
import '../../widgets/charts/nutrients_summary.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/layout/emoji_box.dart';
import '../../widgets/sheets/food_quantity_sheet.dart';

/// Formulário de refeição: cria quando [meal] é nulo, edita caso contrário.
class MealFormPage extends StatefulWidget {
  const MealFormPage({super.key, this.meal});

  final Meal? meal;

  @override
  State<MealFormPage> createState() => _MealFormPageState();
}

class _MealFormPageState extends State<MealFormPage> {
  late MealType _type;
  late List<MealItem> _items;
  ValidationError? _itemsError;

  bool get _isEditing => widget.meal != null;

  @override
  void initState() {
    super.initState();
    _type = widget.meal?.type ?? _suggestedType(DateTime.now());
    _items = [...?widget.meal?.items];
  }

  /// Sugere o tipo pelo horário para agilizar o cadastro.
  static MealType _suggestedType(DateTime now) => switch (now.hour) {
    >= 5 && < 11 => MealType.breakfast,
    >= 11 && < 15 => MealType.lunch,
    >= 18 && < 23 => MealType.dinner,
    _ => MealType.snack,
  };

  Future<void> _addItem() async {
    final item = await Navigator.of(context).pushNamed(AppRoutes.foodSearch);
    if (item is! MealItem) return;
    setState(() {
      _items = [..._items, item];
      _itemsError = null;
    });
  }

  Future<void> _editItem(int index) async {
    final current = _items[index];
    final item = await showFoodQuantitySheet(
      context,
      food: current.food,
      initial: current,
    );
    if (item == null) return;
    setState(() => _items = [..._items]..[index] = item);
  }

  void _removeItem(int index) =>
      setState(() => _items = [..._items]..removeAt(index));

  Future<void> _save() async {
    final controller = context.read<MealController>();
    final error = controller.validateItems(_items);
    if (error != null) {
      setState(() => _itemsError = error);
      return;
    }

    if (_isEditing) {
      await controller.updateMeal(
        widget.meal!.copyWith(type: _type, items: _items),
      );
    } else {
      await controller.addMeal(type: _type, items: _items);
    }
    if (!mounted) return;
    _closeWithMessage(AppStrings.mealSaved);
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.mealDeleteTitle,
      message: AppStrings.mealDeleteMessage,
      confirmLabel: AppStrings.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await context.read<MealController>().deleteMeal(widget.meal!);
    if (!mounted) return;
    _closeWithMessage(AppStrings.mealDeleted);
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.mealEditTitle : AppStrings.mealNewTitle),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: AppStrings.commonDelete,
              onPressed: _delete,
              color: AppColors.error,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        children: [
          Text(AppStrings.mealTypeLabel, style: textTheme.labelLarge),
          const SizedBox(height: AppConstants.spacingSm),
          Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: [
              for (final type in MealType.values)
                ChoiceChip(
                  avatar: Text(type.emoji),
                  label: Text(type.label),
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
          Text(AppStrings.mealFoodsLabel, style: textTheme.labelLarge),
          const SizedBox(height: AppConstants.spacingSm),
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
              ),
              child: Text(
                AppStrings.mealNoFoods,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceSecondary,
                ),
              ),
            ),
          for (final (index, item) in _items.indexed)
            _MealItemTile(
              item: item,
              onTap: () => _editItem(index),
              onRemove: () => _removeItem(index),
            ),
          const SizedBox(height: AppConstants.spacingSm),
          OutlinedButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add_rounded),
            label: Text(AppStrings.mealAddFood),
          ),
          if (_itemsError != null) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              _itemsError!.message,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppConstants.spacingXl),
          Text(AppStrings.mealTotalLabel, style: textTheme.labelLarge),
          const SizedBox(height: AppConstants.spacingMd),
          NutrientsSummary(items: _items),
        ],
      ),
      bottomNavigationBar: FormActionsBar(
        onCancel: () => Navigator.of(context).pop(),
        onSave: _save,
      ),
    );
  }
}

class _MealItemTile extends StatelessWidget {
  const _MealItemTile({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final MealItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: EmojiBox(emoji: item.food.emoji),
      title: Text(item.food.name),
      subtitle: Text(
        '${item.quantityLabel} · '
        '${formatNumber(item.calories)} ${AppStrings.unitKcal}',
        style: const TextStyle(color: AppColors.onSurfaceSecondary),
      ),
      trailing: IconButton(
        tooltip: AppStrings.mealRemoveFood,
        onPressed: onRemove,
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }
}
