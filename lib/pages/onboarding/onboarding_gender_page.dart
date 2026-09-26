import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/l10n/l10n_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../models/enums/gender.dart';
import '../../widgets/cards/gender_option_card.dart';
import '../../widgets/layout/onboarding_scaffold.dart';

class OnboardingGenderPage extends StatelessWidget {
  const OnboardingGenderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<OnboardingController>();

    return OnboardingScaffold(
      step: 2,
      title: l10n.onboardingGenderTitle,
      subtitle: l10n.onboardingGenderSubtitle,
      onNext: controller.gender == null
          ? null
          : () =>
                Navigator.of(context).pushNamed(AppRoutes.onboardingBirthdate),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              for (final gender in Gender.values) ...[
                if (gender != Gender.values.first)
                  const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: GenderOptionCard(
                    emoji: gender.emoji,
                    label: gender.label(l10n),
                    selected: controller.gender == gender,
                    onTap: () => controller.selectGender(gender),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
