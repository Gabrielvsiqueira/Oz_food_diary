/// Período mostrado no gráfico de peso; [days] nulo mostra tudo.
enum WeightPeriod {
  days30(30),
  days90(90),
  all(null);

  const WeightPeriod(this.days);

  final int? days;
}
