import '../configs/constants/nutrition_constants.dart';

sealed class ValidationError {
  const ValidationError();
}

class RequiredError extends ValidationError {
  const RequiredError();
}

class InvalidNumberError extends ValidationError {
  const InvalidNumberError();
}

class MustBePositiveError extends ValidationError {
  const MustBePositiveError();
}

class MustBeNonNegativeError extends ValidationError {
  const MustBeNonNegativeError();
}

class OutOfRangeError extends ValidationError {
  const OutOfRangeError(this.min, this.max);
  final num min;
  final num max;
}

class InvalidEmailError extends ValidationError {
  const InvalidEmailError();
}

class PasswordTooShortError extends ValidationError {
  const PasswordTooShortError();
}

class PasswordMismatchError extends ValidationError {
  const PasswordMismatchError();
}

class InvalidDateError extends ValidationError {
  const InvalidDateError();
}

class AgeOutOfRangeError extends ValidationError {
  const AgeOutOfRangeError(this.min, this.max);
  final int min;
  final int max;
}

class EmptyMacrosError extends ValidationError {
  const EmptyMacrosError();
}

class Validators {
  Validators._();

  static const minPasswordLength = 8;
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Aceita vírgula ou ponto como separador decimal.
  static double? parseDecimal(String? value) {
    if (value == null) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  static DateTime? parseDate(String? value) {
    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$')
        .firstMatch(value?.trim() ?? '');
    if (match == null) return null;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      return null;
    }
    return date;
  }

  static ValidationError? required(String? value) =>
      (value == null || value.trim().isEmpty) ? const RequiredError() : null;

  static ValidationError? email(String? value) {
    final error = required(value);
    if (error != null) return error;
    return _emailRegex.hasMatch(value!.trim())
        ? null
        : const InvalidEmailError();
  }

  static ValidationError? password(String? value) {
    final error = required(value);
    if (error != null) return error;
    return value!.length < minPasswordLength
        ? const PasswordTooShortError()
        : null;
  }

  static ValidationError? passwordConfirmation(String? value, String password) {
    final error = required(value);
    if (error != null) return error;
    return value != password ? const PasswordMismatchError() : null;
  }

  static ValidationError? positiveNumber(String? value) {
    final error = required(value);
    if (error != null) return error;
    final number = parseDecimal(value);
    if (number == null) return const InvalidNumberError();
    return number <= 0 ? const MustBePositiveError() : null;
  }

  static ValidationError? nonNegativeNumber(String? value) {
    final error = required(value);
    if (error != null) return error;
    final number = parseDecimal(value);
    if (number == null) return const InvalidNumberError();
    return number < 0 ? const MustBeNonNegativeError() : null;
  }

  static ValidationError? numberInRange(String? value, num min, num max) {
    final error = positiveNumber(value);
    if (error != null) return error;
    final number = parseDecimal(value)!;
    return (number < min || number > max) ? OutOfRangeError(min, max) : null;
  }

  static ValidationError? height(String? value) => numberInRange(
    value,
    NutritionConstants.minHeightCm,
    NutritionConstants.maxHeightCm,
  );

  static ValidationError? weight(String? value) => numberInRange(
    value,
    NutritionConstants.minWeightKg,
    NutritionConstants.maxWeightKg,
  );

  static ValidationError? birthDate(DateTime? date, {DateTime? now}) {
    if (date == null) return const InvalidDateError();
    final today = now ?? DateTime.now();
    if (date.isAfter(today)) return const InvalidDateError();
    var age = today.year - date.year;
    if (today.month < date.month ||
        (today.month == date.month && today.day < date.day)) {
      age--;
    }
    if (age < NutritionConstants.minAge || age > NutritionConstants.maxAge) {
      return const AgeOutOfRangeError(
        NutritionConstants.minAge,
        NutritionConstants.maxAge,
      );
    }
    return null;
  }
}
