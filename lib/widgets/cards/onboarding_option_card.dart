import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/theme/app_colors.dart';
import '../layout/emoji_box.dart';
import '../layout/selectable_surface.dart';

/// Opção selecionável em lista (objetivo, nível de atividade).
class OnboardingOptionCard extends StatelessWidget {
  const OnboardingOptionCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SelectableSurface(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          EmojiBox(emoji: emoji),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
