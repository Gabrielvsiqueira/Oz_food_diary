import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/configs/strings/app_strings.dart';
import 'package:oz_contador_de_calorias/models/product_info.dart';
import 'package:oz_contador_de_calorias/pages/product_form/product_form_page.dart';

void main() {
  /// Abre o formulário por cima de uma tela vazia e devolve o resultado.
  Future<ProductInfo? Function()> open(
    WidgetTester tester,
    ProductInfo product,
  ) async {
    // Alto o bastante para a lista montar todos os campos.
    tester.view
      ..physicalSize = const Size(800, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ProductInfo? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductFormPage(product: product),
                  ),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return () => result;
  }

  Finder field(String label) => find.descendant(
    of: find
        .ancestor(of: find.text(label), matching: find.byType(Column))
        .first,
    matching: find.byType(TextFormField),
  );

  testWidgets('produto incompleto vem preenchido e exige o que falta', (
    tester,
  ) async {
    final result = await open(
      tester,
      const ProductInfo(
        barcode: '7891000100103',
        name: 'Granola',
        kcalPer100g: 400,
      ),
    );

    expect(find.text(AppStrings.productFormCompleteTitle), findsOneWidget);
    expect(find.text('Granola'), findsOneWidget);
    expect(find.text('400'), findsOneWidget);

    await tester.tap(find.text(AppStrings.commonSave));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.errorRequired), findsNWidgets(3));

    await tester.enterText(field(AppStrings.carbs), '64');
    await tester.enterText(field(AppStrings.protein), '10,5');
    await tester.enterText(field(AppStrings.fat), '12');
    await tester.tap(find.text(AppStrings.commonSave));
    await tester.pumpAndSettle();

    final product = result()!;
    expect(product.barcode, '7891000100103');
    expect(product.isComplete, isTrue);
    expect(product.proteinPer100g, 10.5);
    expect(product.servingGrams, isNull);
  });

  testWidgets('produto desconhecido abre o cadastro em branco', (tester) async {
    await open(tester, const ProductInfo(barcode: '12345678'));
    expect(find.text(AppStrings.productFormNewTitle), findsOneWidget);
  });
}
