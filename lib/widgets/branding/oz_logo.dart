import 'package:flutter/material.dart';

import '../../configs/theme/app_colors.dart';

class OzLogo extends StatelessWidget {
  const OzLogo({super.key, this.fontSize = 72});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Oz',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontFamily: 'Georgia',
            fontFamilyFallback: const ['serif', 'Times New Roman'],
            fontStyle: FontStyle.italic,
            fontSize: fontSize,
            height: 1,
            color: Colors.white,
          ),
          children: const [
            TextSpan(text: 'O'),
            TextSpan(
              text: 'z',
              style: TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
