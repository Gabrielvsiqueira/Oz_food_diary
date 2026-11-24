/// Remove o horário, deixando só o dia (usado como chave dos DailyLogs).
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime today() => dateOnly(DateTime.now());

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Idade completa em [date] de quem nasceu em [birthDate].
int ageOn(DateTime birthDate, DateTime date) {
  final hadBirthday =
      date.month > birthDate.month ||
      (date.month == birthDate.month && date.day >= birthDate.day);
  return date.year - birthDate.year - (hadBirthday ? 0 : 1);
}

/// Data de nascimento estimada para quem informou só a idade: o mesmo dia de
/// hoje, [age] anos atrás. A idade sobe sozinha a cada ano, e o erro em
/// relação ao aniversário real é de menos de um ano. Em 29/02, usa 28/02
/// para não cair em março e errar a idade.
DateTime birthDateForAge(int age, {DateTime? now}) {
  final day = dateOnly(now ?? DateTime.now());
  final estimate = DateTime(day.year - age, day.month, day.day);
  return estimate.month == day.month
      ? estimate
      : DateTime(day.year - age, day.month + 1, 0);
}
