import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/onboarding_controller.dart';
import '../buttons/next_arrow_button.dart';

/// Estrutura comum das etapas do onboarding: voltar + barra de progresso,
/// título/subtítulo centralizados, conteúdo e rodapé.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.body,
    this.subtitle,
    this.onNext,
    this.footer,
  });

  /// Etapa atual, de 1 a [OnboardingController.totalSteps].
  final int step;
  final String title;
  final String? subtitle;
  final Widget body;

  /// Ação do botão de seta. Nulo = desabilitado. Ignorado se houver [footer].
  final VoidCallback? onNext;

  /// Substitui o botão de seta (ex.: "Criar conta").
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingSm,
                vertical: AppConstants.spacingSm,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: canPop ? const BackButton() : null,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          end: (step - 1) / OnboardingController.totalSteps,
                        ),
                        duration: AppConstants.animationDuration,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: 4,
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48 + AppConstants.spacingSm),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppConstants.spacingXl),
                    Text(
                      title,
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(
                        subtitle!,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    Expanded(child: body),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingXl,
                AppConstants.spacingMd,
                AppConstants.spacingXl,
                AppConstants.spacingXl,
              ),
              child:
                  footer ??
                  Align(
                    alignment: Alignment.centerRight,
                    child: NextArrowButton(onPressed: onNext),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
