import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/routes/app_routes.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/food_search_controller.dart';
import '../../models/enums/food_source.dart';
import '../../models/food.dart';
import '../../models/product_info.dart';
import '../../models/product_lookup_failure.dart';
import '../../repositories/food_repository.dart';
import '../../services/barcode_lookup_service.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/dialogs/progress_dialog.dart';
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

  /// Lê o código, procura o produto e segue para a quantidade. Produto
  /// incompleto ou desconhecido passa antes pelo formulário.
  Future<void> _scan(BuildContext context) async {
    final barcode = await Navigator.of(
      context,
    ).pushNamed<String>(AppRoutes.barcodeScanner);
    if (barcode == null || !context.mounted) return;

    final lookup = context.read<BarcodeLookupService>();
    final BarcodeLookupResult result;
    try {
      result = await showProgressDialog(
        context,
        task: lookup.lookup(barcode),
        message: AppStrings.barcodeSearching,
      );
    } on ProductLookupFailure catch (failure) {
      if (context.mounted) _showMessage(context, failure.message);
      return;
    }
    if (!context.mounted) return;

    final Food? food;
    switch (result) {
      case BarcodeFoodFound(food: final found):
        food = found;
      case BarcodeProductIncomplete(:final product):
        food = await _complete(context, product, FoodSource.off);
      case BarcodeProductNotFound(:final barcode):
        food = await _registerUnknown(context, barcode);
    }
    if (food != null && context.mounted) await _select(context, food);
  }

  Future<Food?> _registerUnknown(BuildContext context, String barcode) async {
    final register = await showConfirmDialog(
      context,
      title: AppStrings.barcodeNotFoundTitle,
      message: AppStrings.barcodeNotFoundMessage(barcode),
      confirmLabel: AppStrings.barcodeRegister,
    );
    if (!register || !context.mounted) return null;
    return _complete(context, ProductInfo(barcode: barcode), FoodSource.custom);
  }

  Future<Food?> _complete(
    BuildContext context,
    ProductInfo product,
    FoodSource source,
  ) async {
    final lookup = context.read<BarcodeLookupService>();
    final completed = await Navigator.of(
      context,
    ).pushNamed<ProductInfo>(AppRoutes.productForm, arguments: product);
    if (completed == null) return null;
    return lookup.save(completed, source: source);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: AppConstants.snackBarDuration),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FoodSearchController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.foodSearchTitle),
        actions: [
          IconButton(
            tooltip: AppStrings.barcodeScanTooltip,
            onPressed: () => _scan(context),
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
      ),
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
                _Message(
                  text: AppStrings.foodSearchNoResults(controller.query),
                ),
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
