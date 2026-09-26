import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/theme/app_colors.dart';

class EmojiBox extends StatelessWidget {
  const EmojiBox({super.key, required this.emoji, this.size = 40});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.45)),
    );
  }
}
