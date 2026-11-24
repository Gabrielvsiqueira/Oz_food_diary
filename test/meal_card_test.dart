import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/models/enums/meal_type.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/models/meal.dart';
import 'package:oz_contador_de_calorias/models/meal_item.dart';
import 'package:oz_contador_de_calorias/widgets/cards/meal_card.dart';

/// PNG de [width]×[height] pixels, de uma cor só.
Future<List<int>> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = Colors.green,
  );
  final image = await recorder.endRecording().toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

void main() {
  testWidgets('a miniatura de uma foto deitada cobre o quadrado sem ampliar', (
    tester,
  ) async {
    final dir = await tester.runAsync(
      () => Directory.systemTemp.createTemp('oz_card_test'),
    );
    addTearDown(() => dir!.deleteSync(recursive: true));
    final file = File('${dir!.path}/foto.png');
    await tester.runAsync(() async => file.writeAsBytes(await _png(400, 300)));

    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MealCard(
            meal: Meal(
              id: 'meal-1',
              type: MealType.lunch,
              items: const [
                MealItem(
                  food: MockFoods.egg,
                  portion: FoodPortion.gram,
                  quantity: 50,
                ),
              ],
              createdAt: DateTime(2026, 10, 28, 12),
              photoPath: file.path,
            ),
            onTap: () {},
          ),
        ),
      ),
    );
    // A decodificação acontece fora do relógio falso do teste.
    for (var i = 0; i < 20 && _decoded(tester) == null; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }

    final image = _decoded(tester)!;
    // Quadrado de 48 pt × 3 = 144 px: o lado menor (altura) fica com 144.
    expect(image.height, 144);
    expect(image.width, 192);
  });
}

ui.Image? _decoded(WidgetTester tester) {
  final raw = find.byType(RawImage);
  if (raw.evaluate().isEmpty) return null;
  return tester.widget<RawImage>(raw.first).image;
}
