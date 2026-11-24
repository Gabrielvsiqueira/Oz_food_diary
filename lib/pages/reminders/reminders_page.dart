import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/reminder_controller.dart';
import '../../models/meal_reminder.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/layout/emoji_box.dart';

/// Horário e liga/desliga de cada lembrete de refeição.
class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  Future<void> _allow(BuildContext context) async {
    final granted = await context
        .read<ReminderController>()
        .requestPermission();
    if (granted || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.remindersPermissionDenied),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReminderController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.remindersTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        children: [
          if (controller.permissionGranted == false) ...[
            _PermissionCard(onAllow: () => _allow(context)),
            const SizedBox(height: AppConstants.spacingLg),
          ],
          for (final reminder in controller.reminders) ...[
            _ReminderTile(reminder: reminder),
            const SizedBox(height: AppConstants.spacingSm),
          ],
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            AppStrings.remindersHint,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.onAllow});

  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
        border: Border.all(color: AppColors.carbs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.carbs,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                AppStrings.remindersPermissionTitle,
                style: textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            AppStrings.remindersPermissionMessage,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          PrimaryButton(
            label: AppStrings.remindersPermissionAllow,
            onPressed: onAllow,
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});

  final MealReminder reminder;

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
    );
    if (picked == null || !context.mounted) return;
    await context.read<ReminderController>().setTime(
      reminder.type,
      hour: picked.hour,
      minute: picked.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          EmojiBox(emoji: reminder.type.emoji),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(reminder.type.label, style: textTheme.titleMedium),
          ),
          TextButton(
            onPressed: reminder.enabled ? () => _pickTime(context) : null,
            child: Text(
              MaterialLocalizations.of(
                context,
              ).formatTimeOfDay(time, alwaysUse24HourFormat: true),
              style: textTheme.titleMedium?.copyWith(
                color: reminder.enabled
                    ? AppColors.primary
                    : AppColors.onSurfaceMuted,
              ),
            ),
          ),
          Switch(
            value: reminder.enabled,
            onChanged: (enabled) => context
                .read<ReminderController>()
                .setEnabled(reminder.type, enabled: enabled),
          ),
        ],
      ),
    );
  }
}
