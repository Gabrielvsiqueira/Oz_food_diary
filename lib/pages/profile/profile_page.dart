import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/constants/nutrition_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/session_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../models/auth_failure.dart';
import '../../models/enums/gender.dart';
import '../../services/date_utils.dart';
import '../../services/validators.dart';
import '../../widgets/avatar/initials_avatar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/gender_option_card.dart';
import '../../widgets/cards/sync_status_card.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/dialogs/progress_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/wheel_picker.dart';
import '../../widgets/sheets/wheel_picker_sheet.dart';
import '../login/sign_in_flow.dart';

/// Aba "Perfil". Mudar peso ou altura pede confirmação e recalcula as metas.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _ageText = TextEditingController();
  final _heightText = TextEditingController();
  final _weightText = TextEditingController();
  late int _age;
  late int _height;
  late double _weight;
  late Gender _gender;
  late final ProfileController _profileController;
  late double _shownWeight;

  @override
  void initState() {
    super.initState();
    _profileController = context.read<ProfileController>()
      ..addListener(_syncWeight);
    final profile = _profileController.profile;
    _shownWeight = profile.weight;
    _name = TextEditingController(text: profile.name)..addListener(_refresh);
    _setAge(profile.age);
    _setHeight(profile.height.round());
    _setWeight(profile.weight);
    _gender = profile.gender;
  }

  void _setAge(int age) {
    _age = age;
    _ageText.text = AppStrings.ageValue(age);
  }

  void _setHeight(int height) {
    _height = height;
    _heightText.text = '$height ${AppStrings.unitCm}';
  }

  void _setWeight(double weight) {
    _weight = weight;
    _weightText.text = '${formatEditableNumber(weight)} ${AppStrings.unitKg}';
  }

  /// Peso registrado na aba Evolução (ou baixado pela sincronização)
  /// aparece aqui; sem isso, salvar o Perfil voltaria ao peso antigo.
  void _syncWeight() {
    final weight = _profileController.profile.weight;
    if (weight == _shownWeight) return;
    // Não descarta um peso escolhido aqui e ainda não salvo.
    final edited = _weight != _shownWeight;
    _shownWeight = weight;
    if (!edited) setState(() => _setWeight(weight));
  }

  @override
  void dispose() {
    _profileController.removeListener(_syncWeight);
    for (final c in [_name, _ageText, _heightText, _weightText]) {
      c.dispose();
    }
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _pickAge() async {
    final age = await showWheelPickerSheet(
      context,
      title: AppStrings.ageLabel,
      initial: _age,
      builder: (value, onChanged) => IntWheelPicker(
        min: NutritionConstants.minAge,
        max: NutritionConstants.maxAge,
        value: value,
        unit: AppStrings.unitYears,
        onChanged: onChanged,
      ),
    );
    if (age != null && mounted) setState(() => _setAge(age));
  }

  Future<void> _pickHeight() async {
    final height = await showWheelPickerSheet(
      context,
      title: AppStrings.heightLabel,
      initial: _height,
      builder: (value, onChanged) => IntWheelPicker(
        min: NutritionConstants.minHeightCm.toInt(),
        max: NutritionConstants.maxHeightCm.toInt(),
        value: value,
        unit: AppStrings.unitCm,
        onChanged: onChanged,
      ),
    );
    if (height != null && mounted) setState(() => _setHeight(height));
  }

  Future<void> _pickWeight() async {
    final weight = await showWheelPickerSheet(
      context,
      title: AppStrings.weightLabel,
      initial: _weight,
      builder: (value, onChanged) =>
          WeightWheelPicker(value: value, onChanged: onChanged),
    );
    if (weight != null && mounted) setState(() => _setWeight(weight));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<ProfileController>();
    final current = controller.profile;
    final updated = current.copyWith(
      name: _name.text.trim(),
      // Só estima uma data nova se a idade mudou; senão, mantém a salva.
      birthDate: _age == current.age ? null : birthDateForAge(_age),
      heightCm: _height.toDouble(),
      weightKg: _weight,
      gender: _gender,
    );

    final recalculate = controller.requiresRecalculation(updated);
    if (recalculate) {
      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.profileRecalculateTitle,
        message: AppStrings.profileRecalculateMessage,
        confirmLabel: AppStrings.commonYes,
      );
      if (!confirmed || !mounted) return;
    }

    await controller.updateProfile(updated, recalculateGoal: recalculate);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          recalculate
              ? AppStrings.profileGoalsRecalculated
              : AppStrings.profileSaved,
        ),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  /// Sair apaga os dados do aparelho: antes, tenta enviar o que falta e,
  /// se algo não subir, avisa que será perdido.
  Future<void> _logout() async {
    final sync = context.read<SyncController>();
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.profileLogoutTitle,
      message: sync.isEnabled
          ? AppStrings.profileLogoutSyncedMessage
          : AppStrings.profileLogoutMessage,
      confirmLabel: AppStrings.profileLogout,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    if (sync.isEnabled) {
      final pending = await showProgressDialog(
        context,
        task: sync.flushBeforeLogout(),
        message: AppStrings.profileLogoutSending,
      );
      if (!mounted) return;
      if (pending > 0) {
        final leave = await showConfirmDialog(
          context,
          title: AppStrings.profileLogoutPendingTitle,
          message: AppStrings.profileLogoutPendingMessage(pending),
          confirmLabel: AppStrings.profileLogoutAnyway,
          destructive: true,
        );
        if (!leave || !mounted) return;
      }
    }

    sync.stop();
    await context.read<SessionController>().logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.profileDeleteAccountTitle,
      message: AppStrings.profileDeleteAccountMessage,
      confirmLabel: AppStrings.profileDeleteAccount,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final sync = context.read<SyncController>()..stop();
    try {
      await context.read<SessionController>().deleteAccount();
    } on AuthFailure catch (failure) {
      sync.resume();
      if (mounted) showAuthFailure(context, failure);
      return;
    }
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(AppStrings.profileAccountDeleted),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profileTitle),
        actions: [
          IconButton(
            tooltip: AppStrings.profileLogout,
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          children: [
            Center(child: InitialsAvatar(name: _name.text, size: 80)),
            const SizedBox(height: AppConstants.spacingXl),
            AppTextField(
              label: AppStrings.nameLabel,
              controller: _name,
              textCapitalization: TextCapitalization.words,
              validator: fieldValidator(Validators.required),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            _WheelField(
              label: AppStrings.ageLabel,
              controller: _ageText,
              onTap: _pickAge,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            _WheelField(
              label: AppStrings.heightLabel,
              controller: _heightText,
              onTap: _pickHeight,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            _WheelField(
              label: AppStrings.weightLabel,
              controller: _weightText,
              onTap: _pickWeight,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(AppStrings.sexLabel, style: textTheme.labelLarge),
            const SizedBox(height: AppConstants.spacingSm),
            Row(
              children: [
                for (final gender in Gender.values) ...[
                  if (gender != Gender.values.first)
                    const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: GenderOptionCard(
                      emoji: gender.emoji,
                      label: gender.label,
                      selected: _gender == gender,
                      onTap: () => setState(() => _gender = gender),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppConstants.spacingXl),
            const _SyncStatus(),
            Center(
              child: TextButton(
                onPressed: _deleteAccount,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(AppStrings.profileDeleteAccount),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: PrimaryButton(label: AppStrings.commonSave, onPressed: _save),
        ),
      ),
    );
  }
}

/// Só aparece com a sincronização ligada (Supabase configurado).
class _SyncStatus extends StatelessWidget {
  const _SyncStatus();

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncController>();
    if (!sync.isEnabled) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXl),
      child: SyncStatusCard(
        status: sync.status,
        pendingCount: sync.pendingCount,
        lastSyncedAt: sync.lastSyncedAt,
        onTap: sync.syncNow,
      ),
    );
  }
}

/// Campo só de leitura que abre a roleta ao tocar.
class _WheelField extends StatelessWidget {
  const _WheelField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      readOnly: true,
      onTap: onTap,
      suffixIcon: const Icon(Icons.unfold_more_rounded, size: 20),
    );
  }
}
