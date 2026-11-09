import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../models/enums/gender.dart';
import '../../widgets/inputs/wheel_picker.dart';
import '../../widgets/layout/onboarding_scaffold.dart';

class OnboardingWeightPage extends StatefulWidget {
  const OnboardingWeightPage({super.key});

  @override
  State<OnboardingWeightPage> createState() => _OnboardingWeightPageState();
}

class _OnboardingWeightPageState extends State<OnboardingWeightPage> {
  late double _weight = () {
    final controller = context.read<OnboardingController>();
    return controller.weight ??
        (controller.gender == Gender.female ? 65.0 : 75.0);
  }();

  void _submit() {
    context.read<OnboardingController>().setWeight(_weight);
    Navigator.of(context).pushNamed(AppRoutes.onboardingActivity);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 5,
      title: AppStrings.onboardingWeightTitle,
      subtitle: AppStrings.onboardingEstimateSubtitle,
      onNext: _submit,
      body: Center(
        child: WeightWheelPicker(
          value: _weight,
          onChanged: (weight) => setState(() => _weight = weight),
        ),
      ),
    );
  }
}
