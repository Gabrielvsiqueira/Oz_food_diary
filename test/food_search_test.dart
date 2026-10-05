import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/controllers/food_search_controller.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/models/food.dart';
import 'package:oz_contador_de_calorias/repositories/food_repository.dart';
import 'package:oz_contador_de_calorias/repositories/mock_food_repository.dart';

/// Repositório controlado pelo teste: cada busca fica pendente até ser
/// completada manualmente, o que permite simular respostas fora de ordem.
class _ControlledRepository implements FoodRepository {
  final calls = <String, Completer<List<Food>>>{};

  @override
  Future<List<Food>> search(String query) =>
      (calls[query] = Completer<List<Food>>()).future;
}

void main() {
  group('MockFoodRepository', () {
    const repository = MockFoodRepository(latency: Duration.zero);

    test('com busca vazia retorna todos os alimentos em ordem', () async {
      final results = await repository.search('');
      expect(results, hasLength(MockFoods.all.length));
      expect(results.first.name, 'Alface crespa');
    });

    test('ignora acentos, maiúsculas e ordem das palavras', () async {
      final results = await repository.search('  COZIDO feijao ');
      expect(results.map((f) => f.name), [
        'Feijão carioca cozido',
        'Feijão preto cozido',
      ]);
    });

    test('retorna lista vazia quando nada combina', () async {
      expect(await repository.search('pizza'), isEmpty);
    });
  });

  group('FoodSearchController', () {
    Future<void> flush() => Future<void>.delayed(Duration.zero);

    test('carrega todos os alimentos ao abrir', () async {
      final controller = FoodSearchController(
        const MockFoodRepository(latency: Duration.zero),
      );
      expect(controller.status, FoodSearchStatus.loading);
      await flush();
      expect(controller.status, FoodSearchStatus.success);
      expect(controller.results, hasLength(MockFoods.all.length));
      controller.dispose();
    });

    test('espera o debounce e busca só o último texto digitado', () async {
      final repository = _ControlledRepository();
      final controller = FoodSearchController(
        repository,
        debounce: const Duration(milliseconds: 20),
      );
      controller
        ..onQueryChanged('a')
        ..onQueryChanged('ar')
        ..onQueryChanged('arroz');
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(repository.calls.keys, ['', 'arroz']);
      controller.dispose();
    });

    test('descarta respostas antigas que chegam depois', () async {
      final repository = _ControlledRepository();
      final controller = FoodSearchController(
        repository,
        debounce: Duration.zero,
      );
      controller.onQueryChanged('ovo');
      await Future<void>.delayed(const Duration(milliseconds: 1));

      repository.calls['ovo']!.complete([MockFoods.egg]);
      repository.calls['']!.complete(MockFoods.all);
      await flush();

      expect(controller.results, [MockFoods.egg]);
      controller.dispose();
    });

    test('expõe erro e permite tentar novamente', () async {
      final repository = _ControlledRepository();
      final controller = FoodSearchController(repository);
      repository.calls['']!.completeError(Exception('sem internet'));
      await flush();
      expect(controller.status, FoodSearchStatus.error);

      controller.retry();
      expect(controller.status, FoodSearchStatus.loading);
      repository.calls['']!.complete([MockFoods.apple]);
      await flush();
      expect(controller.status, FoodSearchStatus.success);
      expect(controller.results, [MockFoods.apple]);
      controller.dispose();
    });
  });
}
