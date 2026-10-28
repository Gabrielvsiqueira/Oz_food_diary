/// Uma medição de peso (no máximo uma por dia).
class WeightEntry {
  const WeightEntry({required this.date, required this.weightKg});

  final DateTime date;
  final double weightKg;
}
