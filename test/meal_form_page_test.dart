import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:oz_contador_de_calorias/configs/routes/route_generator.dart';
import 'package:oz_contador_de_calorias/controllers/daily_log_controller.dart';
import 'package:oz_contador_de_calorias/controllers/meal_controller.dart';
import 'package:oz_contador_de_calorias/pages/meal/meal_form_page.dart';
import 'package:oz_contador_de_calorias/repositories/food_repository.dart';
import 'package:oz_contador_de_calorias/repositories/mock_food_repository.dart';

void main() {
  late DailyLogController dailyLog;

  Future<void> pumpForm(WidgetTester tester) async {
    // Tela de celular alta o bastante para o ListView montar tudo.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    dailyLog = DailyLogController();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<FoodRepository>(
            create: (_) => const MockFoodRepository(latency: Duration.zero),
          ),
          ChangeNotifierProvider.value(value: dailyLog),
          ChangeNotifierProvider(create: (_) => MealController(dailyLog)),
        ],
        child: MaterialApp(
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: RouteGenerator.generate,
          home: const Scaffold(body: Text('home')),
        ),
      ),
    );
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute<void>(builder: (_) => const MealFormPage()));
    await tester.pumpAndSettle();
  }

  /// Abre a busca, filtra por [query] e escolhe o alimento [name].
  Future<void> pickFood(WidgetTester tester, String query, String name) async {
    await tester.tap(find.text('Adicionar alimento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  testWidgets('bloqueia salvar refeição sem alimentos', (tester) async {
    await pumpForm(tester);
    final before = dailyLog.logFor(DateTime.now()).meals.length;
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Adicione ao menos um alimento'), findsOneWidget);
    expect(dailyLog.logFor(DateTime.now()).meals.length, before);
  });

  testWidgets('adiciona alimento pela busca e salva a refeição', (
    tester,
  ) async {
    await pumpForm(tester);
    await pickFood(tester, 'feijao carioca', 'Feijão carioca cozido');

    // Sheet abre com a medida caseira sugerida: 1 concha (86 g).
    expect(find.text('concha (86 g)'), findsOneWidget);
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Feijão carioca cozido'), findsOneWidget);
    expect(find.text('1 concha · 86 g · 65 kcal'), findsOneWidget);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final saved = dailyLog.logFor(DateTime.now()).meals.last;
    expect(saved.items.single.grams, 86);
    expect(saved.calories, 65);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('valida a quantidade no sheet', (tester) async {
    await pumpForm(tester);
    await pickFood(tester, 'banana', 'Banana prata');

    final quantity = find.byType(TextFormField).first;
    await tester.enterText(quantity, '0');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    expect(find.text('Adicionar'), findsOneWidget, reason: 'sheet continua');

    await tester.enterText(quantity, '100');
    await tester.pumpAndSettle();
    expect(find.text('Máximo de 5000 g por alimento'), findsOneWidget);
  });

  testWidgets('edita a quantidade e remove um alimento', (tester) async {
    await pumpForm(tester);
    await pickFood(tester, 'feijao carioca', 'Feijão carioca cozido');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Feijão carioca cozido'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '2');
    await tester.tap(find.text('Atualizar'));
    await tester.pumpAndSettle();
    expect(find.text('2 conchas · 172 g · 131 kcal'), findsOneWidget);

    await tester.tap(find.byTooltip('Remover alimento'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum alimento adicionado ainda'), findsOneWidget);
  });

  testWidgets('mostra mensagem quando a busca não encontra nada', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.tap(find.text('Adicionar alimento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'pizza');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(
      find.text('Nenhum alimento encontrado para "pizza"'),
      findsOneWidget,
    );
  });
}
