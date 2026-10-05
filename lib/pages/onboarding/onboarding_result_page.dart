import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/charts/macro_rainbow_chart.dart';
import '../../widgets/charts/macro_summary_row.dart';

class OnboardingResultPage extends StatelessWidget {
  const OnboardingResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profileController = context.watch<ProfileController>();
    final goal = profileController.goal;
    final goalType = profileController.profile.goal;

    String grams(double value) =>
        '${formatNumber(value)}${AppStrings.unitGrams}';

    return Scaffold(
      backgroundColor: AppColors.resultBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.spacingXl),
                children: [
                  const SizedBox(height: AppConstants.spacingXxl),
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.onSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        goalType.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${AppStrings.onboardingResultTitlePrefix} '),
                        TextSpan(
                          text: goalType.title,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                        TextSpan(text: ' ${AppStrings.onboardingResultTitleSuffix}'),
                      ],
                    ),
                    style: textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    AppStrings.onboardingResultDescription,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingXxl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSm,
                    ),
                    child: MacroRainbowChart(
                      showTrack: false,
                      arcs: const [
                        RainbowArc(progress: 1, color: AppColors.calories),
                        RainbowArc(progress: 1, color: AppColors.protein),
                        RainbowArc(progress: 1, color: AppColors.carbs),
                        RainbowArc(progress: 1, color: AppColors.fat),
                      ],
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${formatNumber(goal.caloriesTarget)}${AppStrings.unitKcal}',
                            style: textTheme.titleLarge?.copyWith(
                              color: AppColors.calories,
                            ),
                          ),
                          Text(
                            AppStrings.calories,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                  MacroSummaryRow(
                    items: [
                      MacroSummaryItem(
                        label: AppStrings.protein,
                        value: grams(goal.proteinTargetG),
                        color: AppColors.protein,
                      ),
                      MacroSummaryItem(
                        label: AppStrings.carbs,
                        value: grams(goal.carbsTargetG),
                        color: AppColors.carbs,
                      ),
                      MacroSummaryItem(
                        label: AppStrings.fat,
                        value: grams(goal.fatTargetG),
                        color: AppColors.fat,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingXl),
              child: PrimaryButton(
                label: AppStrings.onboardingResultStart,
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.main, (_) => false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
