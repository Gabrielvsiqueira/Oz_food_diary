import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../services/date_utils.dart';
import '../../services/validators.dart';
import '../buttons/primary_button.dart';
import '../inputs/app_text_field.dart';
import '../inputs/unit_text_field.dart';

typedef WeightLog = ({DateTime date, double weightKg});

/// Pede o peso e o dia da medição (hoje por padrão, para registrar um dia
/// esquecido). [firstDate] é a data mais antiga aceita. Retorna `null` se
/// fechado.
Future<WeightLog?> showWeightEntrySheet(
  BuildContext context, {
  required double initialWeight,
  required DateTime firstDate,
}) => showModalBottomSheet<WeightLog>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: AppColors.surface,
  builder: (_) =>
      _WeightEntrySheet(initialWeight: initialWeight, firstDate: firstDate),
);

class _WeightEntrySheet extends StatefulWidget {
  const _WeightEntrySheet({
    required this.initialWeight,
    required this.firstDate,
  });

  final double initialWeight;
  final DateTime firstDate;

  @override
  State<_WeightEntrySheet> createState() => _WeightEntrySheetState();
}

class _WeightEntrySheetState extends State<_WeightEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  late final _weight = TextEditingController(
    text: formatEditableNumber(widget.initialWeight),
  );
  late final _dateText = TextEditingController(text: formatDayTitle(_date));
  DateTime _date = today();

  @override
  void dispose() {
    _weight.dispose();
    _dateText.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.firstDate,
      lastDate: today(),
    );
    if (picked == null) return;
    setState(() {
      _date = dateOnly(picked);
      _dateText.text = formatDayTitle(_date);
    });
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(
      context,
    ).pop((date: _date, weightKg: Validators.parseDecimal(_weight.text)!));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.weightLogTitle, style: textTheme.titleMedium),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                AppStrings.weightLogHint,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              AppTextField(
                label: AppStrings.weightLogDate,
                controller: _dateText,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              UnitTextField(
                label: AppStrings.weightLabel,
                unit: AppStrings.unitKg,
                controller: _weight,
                textInputAction: TextInputAction.done,
                onSubmitted: _confirm,
                validator: fieldValidator(Validators.weight),
              ),
              const SizedBox(height: AppConstants.spacingXl),
              PrimaryButton(
                label: AppStrings.weightLogSave,
                onPressed: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
