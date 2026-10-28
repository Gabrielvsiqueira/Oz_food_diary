import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/nutrition_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../models/enums/gender.dart';
import '../../widgets/inputs/wheel_picker.dart';
import '../../widgets/layout/onboarding_scaffold.dart';

class OnboardingHeightPage extends StatefulWidget {
  const OnboardingHeightPage({super.key});

  @override
  State<OnboardingHeightPage> createState() => _OnboardingHeightPageState();
}

class _OnboardingHeightPageState extends State<OnboardingHeightPage> {
  /// Começa perto da altura média de adultos no Brasil (IBGE), para rolar
  /// pouco.
  late int _height = () {
    final controller = context.read<OnboardingController>();
    return controller.height?.round() ??
        (controller.gender == Gender.female ? 160 : 173);
  }();

  void _submit() {
    context.read<OnboardingController>().setHeight(_height.toDouble());
    Navigator.of(context).pushNamed(AppRoutes.onboardingWeight);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 4,
      title: AppStrings.onboardingHeightTitle,
      subtitle: AppStrings.onboardingEstimateSubtitle,
      onNext: _submit,
      body: Center(
        child: IntWheelPicker(
          min: NutritionConstants.minHeightCm.toInt(),
          max: NutritionConstants.maxHeightCm.toInt(),
          value: _height,
          unit: AppStrings.unitCm,
          onChanged: (height) => setState(() => _height = height),
        ),
      ),
    );
  }
}
