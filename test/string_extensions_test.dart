import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/configs/strings/string_extensions.dart';
import 'package:oz_contador_de_calorias/services/validators.dart';

void main() {
  test('formatNumber usa ponto como separador de milhar', () {
    expect(formatNumber(2540), '2.540');
    expect(formatNumber(64.6), '65');
  });

  test('formatEditableNumber usa vírgula e volta ao mesmo valor', () {
    expect(formatEditableNumber(2540), '2540');
    expect(formatEditableNumber(80.5), '80,5');
    expect(formatEditableNumber(1.0), '1');
    for (final value in [2540, 80.5, 0.5, 1234.5]) {
      expect(Validators.parseDecimal(formatEditableNumber(value)), value);
    }
  });

  test('mensagens de validação em português', () {
    expect(const RequiredError().message, 'Campo obrigatório');
    expect(
      const OutOfRangeError(100, 250).message,
      'Informe um valor entre 100 e 250',
    );
  });
}
