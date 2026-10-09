import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../configs/theme/app_colors.dart';
import '../../widgets/branding/oz_background.dart';
import '../../widgets/branding/oz_logo.dart';
import '../../widgets/buttons/primary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OzBackground(bottomOpacity: 0.9),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.spacingMd),
                  const Center(child: OzLogo(fontSize: 40)),
                  const Spacer(),
                  Text(
                    AppStrings.welcomeTitle,
                    style: textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                  PrimaryButton(
                    label: AppStrings.welcomeCreateAccount,
                    onPressed: () =>
                        Navigator.of(context)
                            .pushNamed(AppRoutes.onboardingGoal),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  const _GoogleButton(),
                  const SizedBox(height: AppConstants.spacingXl),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        AppStrings.welcomeHaveAccount,
                        style: textTheme.bodyLarge,
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.login),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: textTheme.titleMedium,
                        ),
                        child: Text(AppStrings.welcomeLogin),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Login com Google ainda não existe: botão desabilitado com selo "Em breve".
class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: AppConstants.buttonHeight,
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: AppColors.onSurfaceMuted,
          side: const BorderSide(color: AppColors.border),
          backgroundColor: AppColors.surface.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.g_mobiledata_rounded, size: 28),
            const SizedBox(width: AppConstants.spacingXs),
            Flexible(
              child: Text(
                AppStrings.welcomeGoogle,
                style: textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingSm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
              ),
              child: Text(
                AppStrings.commonComingSoon,
                style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
