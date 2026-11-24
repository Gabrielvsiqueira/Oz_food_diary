import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/database/app_database.dart';
import 'package:oz_contador_de_calorias/models/food.dart';

/// Tabelas criadas depois da versão 1, com a versão em que surgiram.
const _tablesSince = {
  'sync_state': 2,
  'meal_photos': 3,
  'reminder_settings': 4,
};

/// Abre um banco no formato de uma versão antiga do app, como num aparelho
/// que acabou de atualizar: o esquema atual sem as tabelas criadas depois de
/// [version]. [prepare] roda SQL no banco antigo, antes da migração.
Future<AppDatabase> openLegacyDatabase(
  int version, {
  Future<List<Food>> Function()? foodSeed,
  void Function(void Function(String sql) execute)? prepare,
}) async {
  final dir = await Directory.systemTemp.createTemp('oz_legacy_');
  addTearDown(() => dir.delete(recursive: true));
  final file = File('${dir.path}/oz.sqlite');

  final current = AppDatabase(NativeDatabase(file));
  await current.customSelect('SELECT 1').get();
  await current.close();

  final db = AppDatabase(
    NativeDatabase(
      file,
      setup: (raw) {
        if (raw.userVersion <= version) return;
        for (final MapEntry(key: table, value: since) in _tablesSince.entries) {
          if (since > version) raw.execute('DROP TABLE $table');
        }
        // Até a versão 4 os alimentos tinham emoji.
        if (version < 5) {
          raw.execute(
            "ALTER TABLE foods ADD COLUMN emoji TEXT NOT NULL DEFAULT ''",
          );
        }
        raw.userVersion = version;
        prepare?.call(raw.execute);
      },
    ),
    foodSeed: foodSeed,
  );
  addTearDown(db.close);
  return db;
}
