import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/l10n/l10n_extensions.dart';
import '../../controllers/profile_controller.dart';
import '../../models/nutrition_goal.dart';
import '../../services/validators.dart';
import '../../widgets/buttons/form_actions_bar.dart';
import '../../widgets/inputs/unit_text_field.dart';

/// Aba "Metas". Cancelar descarta as edições e volta aos valores atuais.
class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _formKey = GlobalKey<FormState>();
  final _calories = TextEditingController();
  final _carbs = TextEditingController();
  final _protein = TextEditingController();
  final _fat = TextEditingController();
  late final ProfileController _profileController;
  NutritionGoal? _shownGoal;

  @override
  void initState() {
    super.initState();
    _profileController = context.read<ProfileController>();
    _profileController.addListener(_syncWithController);
    _fill(_profileController.goal);
  }

  @override
  void dispose() {
    _profileController.removeListener(_syncWithController);
    for (final c in [_calories, _carbs, _protein, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Metas recalculadas no Perfil aparecem aqui automaticamente.
  void _syncWithController() {
    final goal = _profileController.goal;
    if (!identical(goal, _shownGoal)) _fill(goal);
  }

  void _fill(NutritionGoal goal) {
    _shownGoal = goal;
    // Limpa os erros antes: reset() também restaura o texto antigo dos campos.
    _formKey.currentState?.reset();
    _calories.text = goal.caloriesTarget.toString();
    _carbs.text = formatEditableNumber(goal.carbsTargetG, 'en');
    _protein.text = formatEditableNumber(goal.proteinTargetG, 'en');
    _fat.text = formatEditableNumber(goal.fatTargetG, 'en');
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    _fill(_profileController.goal);
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _profileController.updateGoal(
      NutritionGoal(
        caloriesTarget: Validators.parseDecimal(_calories.text)!.round(),
        carbsTargetG: Validators.parseDecimal(_carbs.text)!,
        proteinTargetG: Validators.parseDecimal(_protein.text)!,
        fatTargetG: Validators.parseDecimal(_fat.text)!,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.goalsSaved),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nonNegative = localizedValidator(
      context,
      Validators.nonNegativeNumber,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          children: [
            UnitTextField(
              label: l10n.calories,
              unit: l10n.unitKcal,
              controller: _calories,
              allowDecimal: false,
              validator: localizedValidator(context, Validators.positiveNumber),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: l10n.carbs,
              unit: l10n.unitGrams,
              controller: _carbs,
              validator: nonNegative,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: l10n.protein,
              unit: l10n.unitGrams,
              controller: _protein,
              validator: nonNegative,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            UnitTextField(
              label: l10n.fat,
              unit: l10n.unitGrams,
              controller: _fat,
              textInputAction: TextInputAction.done,
              onSubmitted: _save,
              validator: nonNegative,
            ),
          ],
        ),
      ),
      bottomNavigationBar: FormActionsBar(onCancel: _cancel, onSave: _save),
    );
  }
}
