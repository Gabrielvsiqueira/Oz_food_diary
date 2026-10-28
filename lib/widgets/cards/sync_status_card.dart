import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../models/enums/sync_status.dart';

/// Estado da sincronização com a conta; tocar sincroniza na hora.
class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({
    super.key,
    required this.status,
    required this.pendingCount,
    required this.lastSyncedAt,
    required this.onTap,
  });

  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncedAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppConstants.radiusXxl);
    final syncing = status == SyncStatus.syncing;
    final (icon, color, title, subtitle) = _describe();

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      child: InkWell(
        onTap: syncing ? null : onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 24,
                child: syncing
                    ? const Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Icon(icon, color: color),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleSmall),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color, String, String?) _describe() => switch (status) {
    SyncStatus.syncing => (
      Icons.sync_rounded,
      AppColors.primary,
      AppStrings.syncStatusSyncing,
      pendingCount > 0 ? AppStrings.syncPending(pendingCount) : null,
    ),
    SyncStatus.offline => (
      Icons.cloud_off_rounded,
      AppColors.onSurfaceSecondary,
      AppStrings.syncStatusOffline,
      pendingCount > 0
          ? AppStrings.syncPendingWhenOnline(pendingCount)
          : AppStrings.syncSavedOnDevice,
    ),
    SyncStatus.failed => (
      Icons.error_outline_rounded,
      AppColors.error,
      AppStrings.syncStatusFailed,
      AppStrings.syncTapToRetry,
    ),
    SyncStatus.idle when pendingCount > 0 => (
      Icons.cloud_upload_outlined,
      AppColors.carbs,
      AppStrings.syncPending(pendingCount),
      AppStrings.syncTapToSync,
    ),
    SyncStatus.idle => (
      Icons.cloud_done_rounded,
      AppColors.primary,
      AppStrings.syncStatusSynced,
      lastSyncedAt == null
          ? AppStrings.syncTapToSync
          : AppStrings.syncLastSyncedAt(
              DateFormat.Hm(appLocale).format(lastSyncedAt!),
            ),
    ),
  };
}
