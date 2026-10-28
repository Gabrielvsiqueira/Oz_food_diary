import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/food_search_controller.dart';
import '../../models/food.dart';
import '../../repositories/food_repository.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/layout/emoji_box.dart';
import '../../widgets/sheets/food_quantity_sheet.dart';

/// Busca um alimento e pede a quantidade. Fecha retornando o `MealItem`.
class FoodSearchPage extends StatelessWidget {
  const FoodSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FoodSearchController(context.read<FoodRepository>()),
      child: const _FoodSearchView(),
    );
  }
}

class _FoodSearchView extends StatelessWidget {
  const _FoodSearchView();

  Future<void> _select(BuildContext context, Food food) async {
    final item = await showFoodQuantitySheet(context, food: food);
    if (item != null && context.mounted) Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FoodSearchController>();

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.foodSearchTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingSm,
              AppConstants.spacingLg,
              AppConstants.spacingMd,
            ),
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: controller.onQueryChanged,
              decoration: InputDecoration(
                hintText: AppStrings.foodSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: switch (controller.status) {
              FoodSearchStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              FoodSearchStatus.error => _Message(
                text: AppStrings.foodSearchError,
                action: PrimaryButton(
                  label: AppStrings.commonRetry,
                  onPressed: controller.retry,
                  variant: PrimaryButtonVariant.secondary,
                ),
              ),
              FoodSearchStatus.success when controller.results.isEmpty =>
                _Message(text: AppStrings.foodSearchNoResults(controller.query)),
              FoodSearchStatus.success => ListView.builder(
                itemCount: controller.results.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.results.length) {
                    return const _SourceCredit();
                  }
                  final food = controller.results[index];
                  return _FoodTile(
                    food: food,
                    onTap: () => _select(context, food),
                  );
                },
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.food, required this.onTap});

  final Food food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
      ),
      leading: EmojiBox(emoji: food.emoji),
      title: Text(food.name),
      subtitle: Text(
        AppStrings.foodPer100g(formatNumber(food.kcalPer100g)),
        style: const TextStyle(color: AppColors.onSurfaceSecondary),
      ),
      trailing: const Icon(Icons.add_rounded, color: AppColors.primary),
    );
  }
}

/// A TACO e o IBGE permitem reproduzir os dados desde que citada a fonte.
class _SourceCredit extends StatelessWidget {
  const _SourceCredit();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Text(
        AppStrings.foodSourceCredit,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceSecondary),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceSecondary,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: AppConstants.spacingLg),
            action!,
          ],
        ],
      ),
    );
  }
}
