import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/routes/app_routes.dart';
import '../../configs/theme/app_colors.dart';
import '../../configs/theme/app_typography.dart';
import '../../controllers/daily_log_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/daily_log.dart';
import '../../models/meal.dart';
import '../../models/nutrition_goal.dart';
import '../../services/date_utils.dart';
import '../../widgets/avatar/initials_avatar.dart';
import '../../widgets/calendar/day_selector.dart';
import '../../widgets/cards/meal_card.dart';
import '../../widgets/charts/macro_rainbow_chart.dart';
import '../../widgets/charts/macro_summary_row.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _pickDate(BuildContext context) async {
    final dailyLog = context.read<DailyLogController>();
    final picked = await showDatePicker(
      context: context,
      initialDate: dailyLog.selectedDate,
      firstDate: DateTime(2000),
      lastDate: today(),
    );
    if (picked != null) dailyLog.selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>();
    final dailyLog = context.watch<DailyLogController>();
    final log = dailyLog.selectedLog;

    // Ícones da status bar escuros sobre o cabeçalho lime.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        floatingActionButton: FloatingActionButton(
          tooltip: AppStrings.homeAddMeal,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.mealForm),
          child: const Icon(Icons.add_rounded),
        ),
        body: Column(
          children: [
            _Header(name: profile.profile.name),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.spacingXl),
                ),
                child: ColoredBox(
                  color: AppColors.background,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 96),
                    children: [
                      const SizedBox(height: AppConstants.spacingMd),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingSm,
                        ),
                        child: DaySelector(
                          label: _dayTitle(dailyLog.selectedDate),
                          onPrevious: dailyLog.goToPreviousDay,
                          onNext: dailyLog.canGoToNextDay
                              ? dailyLog.goToNextDay
                              : null,
                          onLabelTap: () => _pickDate(context),
                          previousTooltip: AppStrings.homePreviousDay,
                          nextTooltip: AppStrings.homeNextDay,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      _DaySummary(log: log, goal: profile.goal),
                      const SizedBox(height: AppConstants.spacingXl),
                      const Divider(),
                      const SizedBox(height: AppConstants.spacingXl),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingLg,
                        ),
                        child: Text(
                          AppStrings.homeMealsSection,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      if (log.meals.isEmpty)
                        _EmptyMeals(isToday: dailyLog.isTodaySelected)
                      else
                        for (final meal in log.meals.reversed)
                          _MealEntry(meal: meal),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Hoje, 12 de julho" / "Ontem, 11 de julho" / "10 de julho".
String _dayTitle(DateTime date) {
  final now = today();
  final format = date.year == now.year
      ? DateFormat.MMMMd(appLocale)
      : DateFormat.yMMMMd(appLocale);
  final formatted = format.format(date);
  final relative = _relativeDay(date);
  return relative == null ? formatted : '$relative, $formatted';
}

String? _relativeDay(DateTime date) {
  final now = today();
  if (isSameDay(date, now)) return AppStrings.homeToday;
  if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return AppStrings.homeYesterday;
  }
  return null;
}

class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacingLg,
          AppConstants.spacingMd,
          AppConstants.spacingLg,
          AppConstants.spacingXl,
        ),
        child: Row(
          children: [
            InitialsAvatar(
              name: name,
              backgroundColor: AppColors.onPrimary,
              foregroundColor: AppColors.primary,
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.homeGreeting,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    name.split(' ').first,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.log, required this.goal});

  final DailyLog log;
  final NutritionGoal goal;

  static double _progress(num value, num target) =>
      target <= 0 ? 0 : value / target;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String n(num value) => formatNumber(value);
    String grams(num value) => '${n(value)}${AppStrings.unitGrams}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSm,
            ),
            child: MacroRainbowChart(
              strokeWidth: 10,
              gap: 4,
              semanticsLabel:
                  '${AppStrings.calories}: ${n(log.totalCalories)} / ${n(goal.caloriesTarget)}',
              arcs: [
                RainbowArc(
                  progress: _progress(log.totalCalories, goal.caloriesTarget),
                  color: AppColors.calories,
                ),
                RainbowArc(
                  progress: _progress(log.totalProteinG, goal.proteinTargetG),
                  color: AppColors.protein,
                ),
                RainbowArc(
                  progress: _progress(log.totalCarbsG, goal.carbsTargetG),
                  color: AppColors.carbs,
                ),
                RainbowArc(
                  progress: _progress(log.totalFatG, goal.fatTargetG),
                  color: AppColors.fat,
                ),
              ],
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: n(log.totalCalories),
                          style: const TextStyle(color: AppColors.calories),
                        ),
                        TextSpan(
                          text: ' / ${n(goal.caloriesTarget)}',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurfaceSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    style: textTheme.headlineSmall,
                  ),
                  Text(
                    AppStrings.calories,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),
          MacroSummaryRow(
            items: [
              MacroSummaryItem(
                label: AppStrings.protein,
                value: n(log.totalProteinG),
                target: grams(goal.proteinTargetG),
                color: AppColors.protein,
              ),
              MacroSummaryItem(
                label: AppStrings.carbs,
                value: n(log.totalCarbsG),
                target: grams(goal.carbsTargetG),
                color: AppColors.carbs,
              ),
              MacroSummaryItem(
                label: AppStrings.fat,
                value: n(log.totalFatG),
                target: grams(goal.fatTargetG),
                color: AppColors.fat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MealEntry extends StatelessWidget {
  const _MealEntry({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm(appLocale).format(meal.createdAt);
    final day =
        _relativeDay(meal.createdAt) ??
        DateFormat.MMMd(appLocale).format(meal.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        0,
        AppConstants.spacingLg,
        AppConstants.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$day, $time',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          MealCard(
            meal: meal,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.mealForm, arguments: meal),
          ),
        ],
      ),
    );
  }
}

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals({required this.isToday});

  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingXl,
      ),
      child: Column(
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: AppConstants.spacingMd),
          Text(AppStrings.homeNoMealsTitle, style: textTheme.titleMedium),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            isToday ? AppStrings.homeNoMealsToday : AppStrings.homeNoMealsPast,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
