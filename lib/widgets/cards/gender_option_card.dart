import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../layout/emoji_box.dart';
import '../layout/selectable_surface.dart';

/// Card vertical de gênero (onboarding e perfil).
class GenderOptionCard extends StatelessWidget {
  const GenderOptionCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SelectableSurface(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXl,
        horizontal: AppConstants.spacingMd,
      ),
      child: Column(
        children: [
          EmojiBox(emoji: emoji, size: 48),
          const SizedBox(height: AppConstants.spacingMd),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
