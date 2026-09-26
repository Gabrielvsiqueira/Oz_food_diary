import 'package:flutter/material.dart';

import '../../configs/theme/app_colors.dart';

class OzBackground extends StatelessWidget {
  const OzBackground({super.key, this.bottomOpacity = 0.5});

  final double bottomOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/background.jpeg', fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.1),
                AppColors.background.withValues(alpha: bottomOpacity),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
