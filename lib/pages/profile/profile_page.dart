import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import '../../services/validators.dart';
import '../../widgets/avatar/initials_avatar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/gender_option_card.dart';
import '../../widgets/cards/sync_status_card.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/dialogs/progress_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/unit_text_field.dart';
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
  late final TextEditingController _height;
  late final TextEditingController _weight;
  final _birthDateText = TextEditingController();
  late DateTime _birthDate;
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
    _height = TextEditingController(text: formatEditableNumber(profile.height));
    _weight = TextEditingController(text: formatEditableNumber(profile.weight));
    _birthDate = profile.birthDate;
    _gender = profile.gender;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _birthDateText.text = _formatDate(_birthDate);
  }

  /// Peso registrado na aba Evolução (ou baixado pela sincronização)
  /// aparece aqui; sem isso, salvar o Perfil voltaria ao peso antigo.
  void _syncWeight() {
    final weight = _profileController.profile.weight;
    if (weight == _shownWeight) return;
    _shownWeight = weight;
    _weight.text = formatEditableNumber(weight);
  }

  @override
  void dispose() {
    _profileController.removeListener(_syncWeight);
    for (final c in [_name, _height, _weight, _birthDateText]) {
      c.dispose();
    }
    super.dispose();
  }

  void _refresh() => setState(() {});

  String _formatDate(DateTime date) => DateFormat.yMd(appLocale).format(date);

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(
        now.year - NutritionConstants.maxAge,
        now.month,
        now.day,
      ),
      lastDate: DateTime(
        now.year - NutritionConstants.minAge,
        now.month,
        now.day,
      ),
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _birthDateText.text = _formatDate(picked);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<ProfileController>();
    final updated = controller.profile.copyWith(
      name: _name.text.trim(),
      birthDate: _birthDate,
      heightCm: Validators.parseDecimal(_height.text),
      weightKg: Validators.parseDecimal(_weight.text),
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
            AppTextField(
              label: AppStrings.birthDateLabel,
              controller: _birthDateText,
              readOnly: true,
              onTap: _pickBirthDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: AppStrings.heightLabel,
              unit: AppStrings.unitCm,
              controller: _height,
              allowDecimal: false,
              validator: fieldValidator(Validators.height),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: AppStrings.weightLabel,
              unit: AppStrings.unitKg,
              controller: _weight,
              textInputAction: TextInputAction.done,
              validator: fieldValidator(Validators.weight),
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
