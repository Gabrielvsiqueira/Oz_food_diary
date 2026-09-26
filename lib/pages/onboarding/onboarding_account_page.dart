import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/l10n/l10n_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../services/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/layout/onboarding_scaffold.dart';

/// "Crie sua conta". Nesta fase só o nome é guardado; e-mail e senha são
/// validados e descartados.
class OnboardingAccountPage extends StatefulWidget {
  const OnboardingAccountPage({super.key});

  @override
  State<OnboardingAccountPage> createState() => _OnboardingAccountPageState();
}

class _OnboardingAccountPageState extends State<OnboardingAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: context.read<OnboardingController>().name ?? '',
    );
    for (final c in [_name, _email, _password, _confirmPassword]) {
      c.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirmPassword]) {
      c.dispose();
    }
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _isValid =>
      Validators.required(_name.text) == null &&
      Validators.email(_email.text) == null &&
      Validators.password(_password.text) == null &&
      Validators.passwordConfirmation(_confirmPassword.text, _password.text) ==
          null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<OnboardingController>().setName(_name.text);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.onboardingLoading, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingScaffold(
      step: 7,
      title: l10n.onboardingAccountTitle,
      subtitle: l10n.onboardingAccountSubtitle,
      footer: PrimaryButton(
        label: l10n.onboardingCreateAccount,
        onPressed: _isValid ? _submit : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(top: AppConstants.spacingXxl),
          children: [
            AppTextField(
              label: l10n.nameLabel,
              hint: l10n.nameHint,
              controller: _name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              validator: localizedValidator(context, Validators.required),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            AppTextField(
              label: l10n.emailLabel,
              hint: l10n.emailHint,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: localizedValidator(context, Validators.email),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            AppTextField(
              label: l10n.passwordLabel,
              hint: l10n.passwordHint,
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              validator: localizedValidator(context, Validators.password),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            AppTextField(
              label: l10n.confirmPasswordLabel,
              hint: l10n.passwordHint,
              controller: _confirmPassword,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: localizedValidator(
                context,
                (value) =>
                    Validators.passwordConfirmation(value, _password.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
