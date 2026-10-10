import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/session_controller.dart';
import '../../models/auth_failure.dart';
import '../../services/validators.dart';
import '../../widgets/branding/oz_background.dart';
import '../../widgets/branding/oz_logo.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';
import 'sign_in_flow.dart';

/// Login (Figma "Login"): fundo da marca com um painel inferior.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(_refresh);
    _password.addListener(_refresh);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _isValid =>
      Validators.email(_email.text) == null &&
      Validators.password(_password.text) == null;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await context.read<SessionController>().login(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) await enterAfterSignIn(context);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showAuthFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OzBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  children: [
                    const BackButton(color: Colors.white),
                    const Spacer(),
                    const OzLogo(fontSize: 40),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppConstants.spacingXl),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.spacingXl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppStrings.loginTitle,
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppConstants.spacingXl),
                            AppTextField(
                              label: AppStrings.emailLabel,
                              hint: AppStrings.emailHint,
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              validator: fieldValidator(Validators.email,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingLg),
                            AppTextField(
                              label: AppStrings.passwordLabel,
                              hint: AppStrings.passwordHint,
                              controller: _password,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              validator: fieldValidator(Validators.password,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXl),
                            PrimaryButton(
                              label: AppStrings.loginButton,
                              onPressed: _isValid && !_submitting
                                  ? _submit
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
