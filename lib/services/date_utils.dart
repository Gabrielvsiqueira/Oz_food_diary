/// Remove o horário, deixando só o dia (usado como chave dos DailyLogs).
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime today() => dateOnly(DateTime.now());

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
