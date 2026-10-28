import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/mocks/mock_foods.dart';
import 'package:oz_contador_de_calorias/models/enums/meal_type.dart';
import 'package:oz_contador_de_calorias/models/food_portion.dart';
import 'package:oz_contador_de_calorias/models/meal.dart';
import 'package:oz_contador_de_calorias/models/meal_item.dart';
import 'package:oz_contador_de_calorias/repositories/drift_meal_repository.dart';
import 'package:oz_contador_de_calorias/services/date_utils.dart';
import 'package:oz_contador_de_calorias/services/meal_photo_storage.dart';
import 'package:oz_contador_de_calorias/services/photo_picker.dart';

/// Seletor que falha com o código de erro do plugin nativo.
class _FailingPicker extends ImagePicker {
  _FailingPicker(this.code);

  final String code;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async => throw PlatformException(code: code);
}

void main() {
  late Directory temp;
  late MealPhotoStorage storage;
  late AppDatabase db;
  late DriftMealRepository meals;

  final lunch = Meal(
    id: 'meal-1',
    type: MealType.lunch,
    items: const [
      MealItem(food: MockFoods.egg, portion: FoodPortion.gram, quantity: 50),
    ],
    createdAt: DateTime.now(),
  );

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('oz_photos_test');
    storage = MealPhotoStorage(Directory('${temp.path}/meal_photos'));
    db = AppDatabase(
      NativeDatabase.memory(),
      clearUserFiles: storage.deleteAll,
    );
    meals = DriftMealRepository(db, photos: storage);
  });

  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });

  /// Uma "foto" recém-tirada, fora da pasta do app (como a do seletor).
  Future<String> picked(String content) async {
    final file = File('${temp.path}/picked-${content.hashCode}.jpg');
    await file.writeAsString(content);
    return file.path;
  }

  Future<Meal> saved() async =>
      (await meals.watchMealsOn(today()).first).single;

  List<String> storedFiles() => storage.directory.existsSync()
      ? storage.directory
            .listSync()
            .map((f) => f.uri.pathSegments.last)
            .toList()
      : const [];

  test('copia a foto para a pasta do app e devolve o caminho', () async {
    final source = await picked('foto 1');

    await meals.save(lunch.withPhoto(source));

    final meal = await saved();
    expect(storage.isStored(meal.photoPath!), isTrue);
    expect(File(meal.photoPath!).readAsStringSync(), 'foto 1');
    expect(File(source).existsSync(), isTrue, reason: 'cópia, não move');
  });

  test('editar sem mexer na foto não copia de novo', () async {
    await meals.save(lunch.withPhoto(await picked('foto 1')));
    final first = await saved();

    await meals.save(first.copyWith(type: MealType.dinner));

    expect((await saved()).photoPath, first.photoPath);
    expect(storedFiles(), hasLength(1));
  });

  test('trocar a foto apaga a anterior', () async {
    await meals.save(lunch.withPhoto(await picked('foto 1')));
    final old = (await saved()).photoPath!;

    await meals.save((await saved()).withPhoto(await picked('foto 2')));

    final meal = await saved();
    expect(File(meal.photoPath!).readAsStringSync(), 'foto 2');
    expect(File(old).existsSync(), isFalse);
    expect(storedFiles(), hasLength(1));
  });

  test('remover a foto apaga o arquivo', () async {
    await meals.save(lunch.withPhoto(await picked('foto 1')));

    await meals.save((await saved()).withPhoto(null));

    expect((await saved()).photoPath, isNull);
    expect(storedFiles(), isEmpty);
    expect(await db.select(db.mealPhotos).get(), isEmpty);
  });

  test('excluir a refeição apaga a foto', () async {
    await meals.save(lunch.withPhoto(await picked('foto 1')));

    await meals.delete(await saved());

    expect(storedFiles(), isEmpty);
    expect(await db.select(db.mealPhotos).get(), isEmpty);
  });

  test('a foto não entra na sincronização', () async {
    await meals.save(lunch);
    final pending = await db.pendingCount();

    await meals.save((await saved()).withPhoto(await picked('foto 1')));

    // Só a refeição e o item continuam pendentes, como sem a foto.
    expect(await db.pendingCount(), pending);
    expect(db.userTables, isNot(contains(db.mealPhotos)));
  });

  test('sair da conta apaga as fotos do aparelho', () async {
    await meals.save(lunch.withPhoto(await picked('foto 1')));

    await db.clearUserData();

    expect(await db.select(db.mealPhotos).get(), isEmpty);
    expect(storage.directory.existsSync(), isFalse);
  });

  test(
    'limpeza apaga fotos de refeições excluídas e arquivos soltos',
    () async {
      await meals.save(lunch.withPhoto(await picked('foto 1')));
      final other = Meal(
        id: 'meal-2',
        type: MealType.snack,
        items: lunch.items,
        createdAt: lunch.createdAt,
      );
      await meals.save(other.withPhoto(await picked('foto 2')));
      // Excluída em outro aparelho: chega pela sincronização, sem passar pelo
      // repositório.
      await (db.update(db.meals)..where((m) => m.id.equals('meal-2'))).write(
        MealsCompanion(deletedAt: Value(DateTime.now().toUtc())),
      );
      await File(storage.pathOf('sobrou.jpg')).writeAsString('?');

      await meals.prunePhotos();

      expect(storedFiles(), [
        File((await saved()).photoPath!).uri.pathSegments.last,
      ]);
      expect((await db.select(db.mealPhotos).get()).single.mealId, 'meal-1');
    },
  );

  test('banco da versão 2 ganha a tabela das fotos', () async {
    final old = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) => raw.execute('PRAGMA user_version = 2'),
      ),
    );
    addTearDown(old.close);
    expect(await old.select(old.mealPhotos).get(), isEmpty);
  });

  group('PhotoPicker', () {
    test('acesso negado vira falha própria', () {
      for (final code in ['camera_access_denied', 'photo_access_restricted']) {
        expect(
          PhotoPicker(_FailingPicker(code)).pick(PhotoSource.camera),
          throwsA(isA<PhotoAccessDeniedFailure>()),
        );
      }
    });

    test('outros erros do sistema viram indisponível', () {
      expect(
        PhotoPicker(
          _FailingPicker('no_available_camera'),
        ).pick(PhotoSource.camera),
        throwsA(isA<PhotoUnavailableFailure>()),
      );
    });
  });
}
