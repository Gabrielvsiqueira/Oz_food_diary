import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../repositories/sync_remote.dart';

typedef SyncResult = ({int pushed, int pulled, bool profileChanged});

/// Sincronização offline-first (ver docs/arquitetura.md, seção 5): envia as
/// linhas marcadas com `is_dirty` e baixa o que mudou no servidor desde o
/// último download. As tabelas têm os mesmos nomes e colunas no aparelho e
/// no servidor, então a conversão é a mesma para todas.
class SyncService {
  SyncService(
    this._db,
    this._remote, {
    this.pageSize = 500,
    this.overlap = const Duration(minutes: 5),
  });

  final AppDatabase _db;
  final SyncRemote _remote;
  final int pageSize;

  /// Margem do download: volta um pouco antes do cursor para pegar
  /// transações que começaram antes da última busca mas só terminaram
  /// depois dela. Linhas que já estão iguais no aparelho são ignoradas.
  final Duration overlap;

  /// Colunas que só existem no aparelho.
  static const _localOnly = {'is_dirty', 'server_updated_at'};

  /// Colunas com nome diferente no servidor.
  static const _remoteNames = {
    'kcal100g': 'kcal_100g',
    'carbs100g': 'carbs_100g',
    'protein100g': 'protein_100g',
    'fat100g': 'fat_100g',
  };

  /// Tabelas que o `ProfileController` lê.
  static const _profileTables = {
    'profiles',
    'nutrition_goals',
    'weight_entries',
  };

  /// Envia e depois baixa. [isActive] devolve `false` se o usuário saiu no
  /// meio do caminho: a partir daí nada mais é gravado no aparelho.
  Future<SyncResult> sync(String userId, {bool Function()? isActive}) async {
    final active = isActive ?? () => true;
    final pushed = await _push(active);
    var pulled = 0;
    var profileChanged = false;
    for (final table in _db.userTables) {
      if (!active()) break;
      final applied = await _pull(table, userId, active);
      pulled += applied;
      if (applied > 0 && _profileTables.contains(table.actualTableName)) {
        profileChanged = true;
      }
    }
    return (pushed: pushed, pulled: pulled, profileChanged: profileChanged);
  }

  Future<int> _push(bool Function() active) async {
    final changes = <String, List<RemoteRow>>{};
    final sent = <TableInfo<Table, Object?>, List<QueryRow>>{};
    for (final table in _db.userTables) {
      final rows = await _db
          .customSelect(
            'SELECT * FROM ${table.actualTableName} WHERE is_dirty = 1',
            readsFrom: {table},
          )
          .get();
      if (rows.isEmpty) continue;
      changes[table.actualTableName] = [
        for (final row in rows) _toRemote(table, row.data),
      ];
      sent[table] = rows;
    }
    if (changes.isEmpty) return 0;

    await _remote.push(changes);
    if (!active()) return 0;

    // Só desmarca o que não foi editado de novo enquanto o pacote subia; a
    // edição nova continua pendente e vai no próximo envio.
    await _db.transaction(() async {
      for (final MapEntry(key: table, value: rows) in sent.entries) {
        for (final row in rows) {
          await _db.customUpdate(
            'UPDATE ${table.actualTableName} SET is_dirty = 0 '
            'WHERE id = ? AND updated_at = ?',
            variables: [
              Variable<String>(row.read<String>('id')),
              Variable<String>(row.data['updated_at'] as String),
            ],
            updates: {table},
          );
        }
      }
    });
    return sent.values.fold<int>(0, (sum, rows) => sum + rows.length);
  }

  Future<int> _pull(
    TableInfo<Table, Object?> table,
    String userId,
    bool Function() active,
  ) async {
    final name = table.actualTableName;
    final cursor = await (_db.select(
      _db.syncState,
    )..where((s) => s.entity.equals(name))).getSingleOrNull();
    final since = cursor == null
        ? DateTime.utc(1970)
        : cursor.pulledUntil.subtract(overlap);
    var latest = cursor?.pulledUntil;
    var applied = 0;

    for (var offset = 0; ; offset += pageSize) {
      final rows = await _remote.pull(
        name,
        ownerColumn: name == 'profiles' ? 'id' : 'user_id',
        ownerId: userId,
        since: since,
        offset: offset,
        limit: pageSize,
      );
      if (!active()) return applied;
      await _db.transaction(() async {
        for (final row in rows) {
          if (await _apply(table, row)) applied++;
        }
      });
      for (final row in rows) {
        final serverUpdatedAt = _serverUpdatedAt(row);
        if (latest == null || serverUpdatedAt.isAfter(latest)) {
          latest = serverUpdatedAt;
        }
      }
      if (rows.length < pageSize) break;
    }

    if (latest case final latest? when active()) {
      await _db
          .into(_db.syncState)
          .insertOnConflictUpdate(
            SyncStateCompanion.insert(entity: name, pulledUntil: latest),
          );
    }
    return applied;
  }

  /// Grava a linha do servidor no aparelho, a menos que a local seja uma
  /// edição mais nova ainda não enviada ou que já esteja igual.
  Future<bool> _apply(TableInfo<Table, Object?> table, RemoteRow row) async {
    final name = table.actualTableName;
    final serverUpdatedAt = _serverUpdatedAt(row);
    final local = await _db
        .customSelect(
          'SELECT is_dirty, updated_at, server_updated_at FROM $name '
          'WHERE id = ?',
          variables: [Variable<String>(row['id'] as String)],
          readsFrom: {table},
        )
        .getSingleOrNull();
    if (local != null) {
      if (local.read<bool>('is_dirty')) {
        final remoteUpdatedAt = DateTime.parse(row['updated_at'] as String);
        if (local.read<DateTime>('updated_at').isAfter(remoteUpdatedAt)) {
          return false;
        }
      } else if (local
              .readNullable<DateTime>('server_updated_at')
              ?.isAtSameMomentAs(serverUpdatedAt) ??
          false) {
        return false;
      }
    }

    final columns = [for (final column in table.$columns) column.$name];
    await _db.customInsert(
      'INSERT INTO $name (${columns.join(', ')}) '
      'VALUES (${List.filled(columns.length, '?').join(', ')}) '
      'ON CONFLICT (id) DO UPDATE SET '
      '${[for (final column in columns)
        if (column != 'id') '$column = excluded.$column'].join(', ')}',
      variables: [
        for (final column in table.$columns)
          _fromRemote(column, row, serverUpdatedAt),
      ],
      updates: {table},
    );
    return true;
  }

  RemoteRow _toRemote(
    TableInfo<Table, Object?> table,
    Map<String, Object?> data,
  ) => {
    for (final column in table.$columns)
      if (!_localOnly.contains(column.$name))
        _remoteNames[column.$name] ??
            column.$name: switch (data[column.$name]) {
          final String value when column.type == DriftSqlType.dateTime =>
            (_db.typeMapping.read(
              DriftSqlType.dateTime,
              value,
            )!).toUtc().toIso8601String(),
          final value => value,
        },
  };

  Variable<Object> _fromRemote(
    GeneratedColumn<Object> column,
    RemoteRow row,
    DateTime serverUpdatedAt,
  ) {
    if (column.$name == 'is_dirty') return const Variable<bool>(false);
    if (column.$name == 'server_updated_at') {
      return Variable<DateTime>(serverUpdatedAt);
    }
    final value = row[_remoteNames[column.$name] ?? column.$name];
    return switch (column.type) {
      DriftSqlType.dateTime => Variable<DateTime>(
        value == null ? null : DateTime.parse(value as String).toUtc(),
      ),
      DriftSqlType.double => Variable<double>((value as num?)?.toDouble()),
      DriftSqlType.int => Variable<int>((value as num?)?.toInt()),
      _ => Variable<String>(value as String?),
    };
  }

  static DateTime _serverUpdatedAt(RemoteRow row) =>
      DateTime.parse(row['server_updated_at'] as String).toUtc();
}
