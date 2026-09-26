import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/l10n/l10n_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../services/validators.dart';
import '../../widgets/layout/onboarding_scaffold.dart';
import 'onboarding_measure_body.dart';

class OnboardingWeightPage extends StatefulWidget {
  const OnboardingWeightPage({super.key});

  @override
  State<OnboardingWeightPage> createState() => _OnboardingWeightPageState();
}

class _OnboardingWeightPageState extends State<OnboardingWeightPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final saved = context.read<OnboardingController>().weight;
    _textController = TextEditingController(
      text: saved == null ? '' : formatEditableNumber(saved, 'pt'),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _isValid => Validators.weight(_textController.text) == null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<OnboardingController>().setWeight(
      Validators.parseDecimal(_textController.text)!,
    );
    Navigator.of(context).pushNamed(AppRoutes.onboardingActivity);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingScaffold(
      step: 5,
      title: l10n.onboardingWeightTitle,
      subtitle: l10n.onboardingEstimateSubtitle,
      onNext: _isValid ? _submit : null,
      body: OnboardingMeasureBody(
        formKey: _formKey,
        controller: _textController,
        label: l10n.weightLabel,
        unit: l10n.unitKg,
        hint: '80',
        validator: Validators.weight,
        onChanged: (_) => setState(() {}),
        onSubmitted: _submit,
      ),
    );
  }
}
