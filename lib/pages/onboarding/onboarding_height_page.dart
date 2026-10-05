import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../services/validators.dart';
import '../../widgets/layout/onboarding_scaffold.dart';
import 'onboarding_measure_body.dart';

class OnboardingHeightPage extends StatefulWidget {
  const OnboardingHeightPage({super.key});

  @override
  State<OnboardingHeightPage> createState() => _OnboardingHeightPageState();
}

class _OnboardingHeightPageState extends State<OnboardingHeightPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final saved = context.read<OnboardingController>().height;
    _textController = TextEditingController(
      text: saved?.round().toString() ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _isValid => Validators.height(_textController.text) == null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<OnboardingController>().setHeight(
      Validators.parseDecimal(_textController.text)!,
    );
    Navigator.of(context).pushNamed(AppRoutes.onboardingWeight);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 4,
      title: AppStrings.onboardingHeightTitle,
      subtitle: AppStrings.onboardingEstimateSubtitle,
      onNext: _isValid ? _submit : null,
      body: OnboardingMeasureBody(
        formKey: _formKey,
        controller: _textController,
        label: AppStrings.heightLabel,
        unit: AppStrings.unitCm,
        hint: '175',
        allowDecimal: false,
        validator: Validators.height,
        onChanged: (_) => setState(() {}),
        onSubmitted: _submit,
      ),
    );
  }
}
