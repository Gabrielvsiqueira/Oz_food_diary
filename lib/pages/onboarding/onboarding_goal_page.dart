import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/l10n/l10n_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../models/enums/goal_type.dart';
import '../../widgets/cards/onboarding_option_card.dart';
import '../../widgets/layout/onboarding_scaffold.dart';

class OnboardingGoalPage extends StatelessWidget {
  const OnboardingGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<OnboardingController>();

    return OnboardingScaffold(
      step: 1,
      title: l10n.onboardingGoalTitle,
      subtitle: l10n.onboardingGoalSubtitle,
      onNext: controller.goal == null
          ? null
          : () => Navigator.of(context).pushNamed(AppRoutes.onboardingGender),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final goal in GoalType.values) ...[
            OnboardingOptionCard(
              emoji: goal.emoji,
              title: goal.label(l10n),
              selected: controller.goal == goal,
              onTap: () => controller.selectGoal(goal),
            ),
            const SizedBox(height: AppConstants.spacingMd),
          ],
        ],
      ),
    );
  }
}
