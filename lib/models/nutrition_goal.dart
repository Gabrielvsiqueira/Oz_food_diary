class NutritionGoal {
  const NutritionGoal({
    required this.caloriesTarget,
    required this.carbsTargetG,
    required this.proteinTargetG,
    required this.fatTargetG,
  });

  final int caloriesTarget;
  final double carbsTargetG;
  final double proteinTargetG;
  final double fatTargetG;

  NutritionGoal copyWith({
    int? caloriesTarget,
    double? carbsTargetG,
    double? proteinTargetG,
    double? fatTargetG,
  }) {
    return NutritionGoal(
      caloriesTarget: caloriesTarget ?? this.caloriesTarget,
      carbsTargetG: carbsTargetG ?? this.carbsTargetG,
      proteinTargetG: proteinTargetG ?? this.proteinTargetG,
      fatTargetG: fatTargetG ?? this.fatTargetG,
    );
  }
}
