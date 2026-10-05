import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../models/enums/activity_level.dart';
import '../../widgets/cards/onboarding_option_card.dart';
import '../../widgets/layout/onboarding_scaffold.dart';

class OnboardingActivityPage extends StatelessWidget {
  const OnboardingActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return OnboardingScaffold(
      step: 6,
      title: AppStrings.onboardingActivityTitle,
      onNext: controller.activityLevel == null
          ? null
          : () => Navigator.of(context).pushNamed(AppRoutes.onboardingAccount),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: AppConstants.spacingXl),
        itemCount: ActivityLevel.values.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppConstants.spacingMd),
        itemBuilder: (context, index) {
          final level = ActivityLevel.values[index];
          return OnboardingOptionCard(
            emoji: level.emoji,
            title: level.label,
            subtitle: level.description,
            selected: controller.activityLevel == level,
            onTap: () => controller.selectActivityLevel(level),
          );
        },
      ),
    );
  }
}
