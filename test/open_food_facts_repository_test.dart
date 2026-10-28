import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oz_contador_de_calorias/models/product_lookup_failure.dart';
import 'package:oz_contador_de_calorias/repositories/open_food_facts_repository.dart';

/// Resposta real (resumida) da Open Food Facts para o Leite Moça.
const _condensedMilk = {
  'code': '7891000100103',
  'status': 1,
  'status_verbose': 'product found',
  'product': {
    'product_name': 'Leite Condensado Integral moça',
    'product_name_pt': 'Leite Condensado Integral moça',
    'brands': 'Nestlé, Moça',
    'serving_quantity': 20,
    'nutriments': {
      'energy-kcal_100g': 325,
      'energy_100g': 1365,
      'carbohydrates_100g': 55,
      'proteins_100g': 7,
      'fat_100g': 8,
    },
  },
};

const _notFound = {'status': 0, 'status_verbose': 'product not found'};

void main() {
  http.Response json(Object body, [int status = 200]) => http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  OpenFoodFactsRepository repository(MockClientHandler handler) =>
      OpenFoodFactsRepository(
        client: MockClient(handler),
        timeout: const Duration(milliseconds: 50),
      );

  test('busca pelo código e converte o produto', () async {
    late http.Request sent;
    final product = await repository((request) async {
      sent = request;
      return json(_condensedMilk);
    }).findByBarcode('7891000100103');

    expect(sent.url.host, 'world.openfoodfacts.org');
    expect(sent.url.path, '/api/v2/product/7891000100103');
    expect(sent.url.queryParameters['fields'], contains('nutriments'));
    expect(sent.headers['User-Agent'], OpenFoodFactsRepository.userAgent);

    expect(product!.isComplete, isTrue);
    expect(product.name, 'Leite Condensado Integral moça · Nestlé');
    expect(product.kcalPer100g, 325);
    expect(product.carbsPer100g, 55);
    expect(product.proteinPer100g, 7);
    expect(product.fatPer100g, 8);
    expect(product.servingGrams, 20);
  });

  test('produto inexistente (404) volta nulo', () async {
    final product = await repository(
      (_) async => json(_notFound, 404),
    ).findByBarcode('7896004000589');
    expect(product, isNull);
  });

  test('código inválido (200 com status 0) volta nulo', () async {
    final product = await repository(
      (_) async => json({'status': 0, 'status_verbose': 'invalid code'}),
    ).findByBarcode('00000000');
    expect(product, isNull);
  });

  group('parseProduct', () {
    test('sem kcal, converte a energia em kJ', () {
      final product = parseProduct('1', {
        'product_name': 'Suco',
        'nutriments': {'energy_100g': 177.82},
      });
      expect(product.kcalPer100g, 42.5);
    });

    test('aceita números em texto e descarta negativos', () {
      final product = parseProduct('1', {
        'product_name': 'Biscoito',
        'serving_quantity': '30',
        'nutriments': {
          'energy-kcal_100g': '450,5',
          'carbohydrates_100g': -1,
          'proteins_100g': 'n/d',
        },
      });
      expect(product.kcalPer100g, 450.5);
      expect(product.carbsPer100g, isNull);
      expect(product.proteinPer100g, isNull);
      expect(product.servingGrams, 30);
    });

    test('faltando nutrientes, fica incompleto', () {
      final product = parseProduct('1', {
        'product_name': 'Granola',
        'nutriments': {'energy-kcal_100g': 400},
      });
      expect(product.isComplete, isFalse);
      expect(product.isEmpty, isFalse);
    });

    test('não repete a marca que já está no nome', () {
      final product = parseProduct('1', {
        'product_name': 'Refrigerante Coca-Cola 2Lt',
        'brands': 'Coca-Cola',
      });
      expect(product.name, 'Refrigerante Coca-Cola 2Lt');
    });

    test('sem nome, usa a marca; sem nada, fica nulo', () {
      expect(parseProduct('1', {'brands': 'Piracanjuba'}).name, 'Piracanjuba');
      expect(parseProduct('1', {'product_name': '  '}).name, isNull);
    });

    test('ignora porção fora do limite', () {
      expect(
        parseProduct('1', {'serving_quantity': 20000}).servingGrams,
        isNull,
      );
      expect(parseProduct('1', {'serving_quantity': 0}).servingGrams, isNull);
    });
  });

  group('falhas', () {
    test('sem conexão', () {
      expect(
        repository(
          (_) async => throw http.ClientException('Failed host lookup'),
        ).findByBarcode('1'),
        throwsA(isA<ProductLookupOfflineFailure>()),
      );
    });

    test('erro de TLS (Wi-Fi com página de login) conta como sem conexão', () {
      expect(
        repository(
          (_) async => throw const HandshakeException('portal cativo'),
        ).findByBarcode('1'),
        throwsA(isA<ProductLookupOfflineFailure>()),
      );
    });

    test('servidor demorando demais conta como sem conexão', () {
      expect(
        repository((_) => Completer<http.Response>().future).findByBarcode('1'),
        throwsA(isA<ProductLookupOfflineFailure>()),
      );
    });

    test('erro do servidor', () {
      expect(
        repository((_) async => http.Response('', 503)).findByBarcode('1'),
        throwsA(isA<ProductLookupServerFailure>()),
      );
    });

    test('resposta que não é JSON', () {
      expect(
        repository(
          (_) async => http.Response('<html>', 200),
        ).findByBarcode('1'),
        throwsA(isA<ProductLookupServerFailure>()),
      );
    });
  });
}
