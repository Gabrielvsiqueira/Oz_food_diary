import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/nutrition_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../widgets/inputs/wheel_picker.dart';
import '../../widgets/layout/onboarding_scaffold.dart';

class OnboardingAgePage extends StatefulWidget {
  const OnboardingAgePage({super.key});

  @override
  State<OnboardingAgePage> createState() => _OnboardingAgePageState();
}

class _OnboardingAgePageState extends State<OnboardingAgePage> {
  static const _initialAge = 25;

  late int _age = context.read<OnboardingController>().age ?? _initialAge;

  void _submit() {
    context.read<OnboardingController>().setAge(_age);
    Navigator.of(context).pushNamed(AppRoutes.onboardingHeight);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 3,
      title: AppStrings.onboardingAgeTitle,
      subtitle: AppStrings.onboardingAgeSubtitle,
      onNext: _submit,
      body: Center(
        child: IntWheelPicker(
          min: NutritionConstants.minAge,
          max: NutritionConstants.maxAge,
          value: _age,
          unit: AppStrings.unitYears,
          onChanged: (age) => setState(() => _age = age),
        ),
      ),
    );
  }
}
