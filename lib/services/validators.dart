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

class InvalidEmailError extends ValidationError {
  const InvalidEmailError();
}

class PasswordTooShortError extends ValidationError {
  const PasswordTooShortError();
}

class PasswordMismatchError extends ValidationError {
  const PasswordMismatchError();
}

class EmptyMealError extends ValidationError {
  const EmptyMealError();
}

class FoodQuantityTooLargeError extends ValidationError {
  const FoodQuantityTooLargeError(this.maxGrams);
  final int maxGrams;
}

class InvalidBarcodeError extends ValidationError {
  const InvalidBarcodeError();
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

  /// Quantidade na medida escolhida (ex.: 2 fatias de 25 g).
  static ValidationError? foodQuantity(String? value, double gramsPerPortion) {
    final error = positiveNumber(value);
    if (error != null) return error;
    final grams = parseDecimal(value)! * gramsPerPortion;
    return grams > NutritionConstants.maxFoodGrams
        ? const FoodQuantityTooLargeError(NutritionConstants.maxFoodGrams)
        : null;
  }

  /// EAN-8, UPC-A (12), EAN-13 ou GTIN-14: só dígitos.
  static ValidationError? barcode(String? value) {
    final error = required(value);
    if (error != null) return error;
    return RegExp(r'^\d{8,14}$').hasMatch(value!.trim())
        ? null
        : const InvalidBarcodeError();
  }

  /// Porção da embalagem, em gramas; opcional.
  static ValidationError? servingGrams(String? value) =>
      (value == null || value.trim().isEmpty) ? null : foodQuantity(value, 1);
}
