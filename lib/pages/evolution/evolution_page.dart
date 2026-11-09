import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/weight_history_controller.dart';
import '../../models/enums/weight_period.dart';
import '../../models/weight_entry.dart';
import '../../repositories/profile_repository.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/charts/weight_line_chart.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/sheets/weight_entry_sheet.dart';

/// Aba "Evolução": gráfico do peso, resumo do período e registro de
/// medições (de hoje ou de um dia esquecido).
class EvolutionPage extends StatelessWidget {
  const EvolutionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          WeightHistoryController(context.read<ProfileRepository>()),
      child: const _EvolutionView(),
    );
  }
}

class _EvolutionView extends StatelessWidget {
  const _EvolutionView();

  static const _chartHeight = 240.0;

  /// Peso de qualquer dia até hoje. Se virar o peso atual (não é anterior à
  /// última medição) e mudar, recalcula as metas com confirmação, como no
  /// Perfil; um dia antigo só entra no histórico.
  Future<void> _logWeight(BuildContext context) async {
    final profile = context.read<ProfileController>();
    final history = context.read<WeightHistoryController>();
    final log = await showWeightEntrySheet(
      context,
      initialWeight: profile.profile.weight,
      firstDate: profile.profile.birthDate,
    );
    if (log == null || !context.mounted) return;
    final recalculate =
        history.becomesCurrent(log.date) &&
        log.weightKg != profile.profile.weight;
    if (recalculate) {
      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.profileRecalculateTitle,
        message: AppStrings.profileRecalculateMessage,
        confirmLabel: AppStrings.commonYes,
      );
      if (!confirmed || !context.mounted) return;
    }
    await profile.logWeight(
      log.date,
      log.weightKg,
      recalculateGoal: recalculate,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          recalculate
              ? AppStrings.profileGoalsRecalculated
              : AppStrings.weightLogged,
        ),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final controller = context.watch<WeightHistoryController>();
    final entries = controller.visibleEntries;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.evolutionTitle)),
      body: !controller.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              children: [
                _Summary(entries: entries, change: controller.change),
                const SizedBox(height: AppConstants.spacingLg),
                Wrap(
                  spacing: AppConstants.spacingSm,
                  children: [
                    for (final period in WeightPeriod.values)
                      _PeriodChip(
                        period: period,
                        selected: controller.period == period,
                        onSelected: () => controller.selectPeriod(period),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),
                SizedBox(
                  height: _chartHeight,
                  child: entries.length >= 2
                      ? WeightLineChart(entries: entries)
                      : Center(
                          child: Text(
                            entries.isEmpty
                                ? AppStrings.weightHistoryEmptyPeriod
                                : AppStrings.weightHistoryOnePoint,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceSecondary,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: AppConstants.spacingXl),
                if (entries.isNotEmpty) ...[
                  Text(
                    AppStrings.weightEntriesTitle,
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  _EntryList(entries: entries),
                ],
              ],
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: PrimaryButton(
            label: AppStrings.weightLogButton,
            onPressed: () => _logWeight(context),
          ),
        ),
      ),
    );
  }
}

/// Atual, início do período e variação, lado a lado.
class _Summary extends StatelessWidget {
  const _Summary({required this.entries, required this.change});

  final List<WeightEntry> entries;
  final double? change;

  @override
  Widget build(BuildContext context) {
    String kg(double value) => '${formatEditableNumber(value)} kg';
    final change = this.change;
    return Row(
      children: [
        _StatTile(
          label: AppStrings.weightCurrent,
          value: entries.isEmpty ? '—' : kg(entries.last.weightKg),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        _StatTile(
          label: AppStrings.weightPeriodStart,
          value: entries.length < 2 ? '—' : kg(entries.first.weightKg),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        _StatTile(
          label: AppStrings.weightChangeLabel,
          value: change == null ? '—' : '${formatSignedWeight(change)} kg',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.period,
    required this.selected,
    required this.onSelected,
  });

  final WeightPeriod period;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(period.label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.onSurface,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.surfaceVariant,
      ),
    );
  }
}

/// Medições do período, da mais recente para a mais antiga, com a diferença
/// para a anterior.
class _EntryList extends StatelessWidget {
  const _EntryList({required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat.yMd(appLocale);
    return Column(
      children: [
        for (var i = entries.length - 1; i >= 0; i--)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(dateFormat.format(entries[i].date)),
            subtitle: i == 0
                ? null
                : Text(
                    '${formatSignedWeight(entries[i].weightKg - entries[i - 1].weightKg)} kg',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceSecondary,
                    ),
                  ),
            trailing: Text(
              '${formatEditableNumber(entries[i].weightKg)} kg',
              style: textTheme.titleMedium,
            ),
          ),
      ],
    );
  }
}
