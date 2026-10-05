import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/onboarding_controller.dart';
import '../../services/validators.dart';
import '../../widgets/inputs/date_text_input_formatter.dart';
import '../../widgets/layout/onboarding_scaffold.dart';

class OnboardingBirthdatePage extends StatefulWidget {
  const OnboardingBirthdatePage({super.key});

  @override
  State<OnboardingBirthdatePage> createState() =>
      _OnboardingBirthdatePageState();
}

class _OnboardingBirthdatePageState extends State<OnboardingBirthdatePage> {
  late final TextEditingController _textController;
  ValidationError? _error;

  @override
  void initState() {
    super.initState();
    final saved = context.read<OnboardingController>().birthDate;
    _textController = TextEditingController(
      text: saved == null ? '' : DateFormat('dd/MM/yyyy').format(saved),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _isFilled => _textController.text.length == 10;

  void _onChanged(String _) {
    setState(() {
      _error = _isFilled
          ? Validators.birthDate(Validators.parseDate(_textController.text))
          : null;
    });
  }

  void _submit() {
    final date = Validators.parseDate(_textController.text);
    final error = Validators.birthDate(date);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    context.read<OnboardingController>().setBirthDate(date!);
    Navigator.of(context).pushNamed(AppRoutes.onboardingHeight);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return OnboardingScaffold(
      step: 3,
      title: AppStrings.onboardingBirthdateTitle,
      subtitle: AppStrings.onboardingBirthdateSubtitle,
      onNext: _isFilled && _error == null ? _submit : null,
      body: Center(
        child: TextField(
          controller: _textController,
          autofocus: true,
          onChanged: _onChanged,
          onSubmitted: (_) => _isFilled ? _submit() : null,
          keyboardType: TextInputType.number,
          inputFormatters: [DateTextInputFormatter()],
          textAlign: TextAlign.center,
          style: textTheme.displaySmall,
          decoration: InputDecoration(
            hintText: AppStrings.onboardingBirthdateHint,
            hintStyle: textTheme.displaySmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
            errorText: _error?.message,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
