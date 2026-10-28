import 'dart:convert';

import 'package:oz_contador_de_calorias/models/sync_failure.dart';
import 'package:oz_contador_de_calorias/repositories/sync_remote.dart';

/// Servidor em memória com as mesmas regras do `push_changes`: upsert no
/// id, só substitui se o `updated_at` recebido for maior, dono vindo da
/// sessão e um `server_updated_at` por envio (como o `now()` da transação).
class FakeSyncServer {
  final tables = <String, Map<String, RemoteRow>>{};
  var _clock = DateTime.utc(2026, 10, 28, 12);

  /// Conta de quem está "logado" nos clientes criados por [client].
  SyncRemote client(String userId) => FakeSyncRemote(this, userId);

  DateTime _tick() => _clock = _clock.add(const Duration(milliseconds: 1));

  List<RemoteRow> rows(String table) => [...?tables[table]?.values];
}

class FakeSyncRemote implements SyncRemote {
  FakeSyncRemote(this.server, this.userId);

  final FakeSyncServer server;
  final String userId;

  /// Próxima chamada falha com esta exceção.
  SyncFailure? failNext;

  /// Chamado no meio do envio, antes da resposta chegar ao aparelho.
  Future<void> Function()? onPush;

  int pushes = 0;

  void _maybeFail() {
    if (failNext case final failure?) {
      failNext = null;
      throw failure;
    }
  }

  @override
  Future<void> push(Map<String, List<RemoteRow>> changes) async {
    _maybeFail();
    pushes++;
    // Passa pelo JSON, como na rede.
    final decoded = (jsonDecode(jsonEncode(changes)) as Map<String, Object?>)
        .cast<String, List<Object?>>();
    final now = server._tick().toIso8601String();
    for (final MapEntry(key: table, value: rows) in decoded.entries) {
      final stored = server.tables[table] ??= {};
      for (final row in rows.cast<Map<String, Object?>>()) {
        final id = row['id']! as String;
        final current = stored[id];
        final incoming = DateTime.parse(row['updated_at']! as String);
        if (current != null &&
            !DateTime.parse(
              current['updated_at']! as String,
            ).isBefore(incoming)) {
          continue;
        }
        stored[id] = {
          ...row,
          if (table != 'profiles') 'user_id': userId,
          'server_updated_at': now,
        };
      }
    }
    await onPush?.call();
  }

  @override
  Future<List<RemoteRow>> pull(
    String table, {
    required String ownerColumn,
    required String ownerId,
    required DateTime since,
    required int offset,
    required int limit,
  }) async {
    _maybeFail();
    final rows =
        server
            .rows(table)
            .where(
              (row) =>
                  row[ownerColumn] == ownerId &&
                  DateTime.parse(
                    row['server_updated_at']! as String,
                  ).isAfter(since),
            )
            .toList()
          ..sort((a, b) {
            final byTime = (a['server_updated_at']! as String).compareTo(
              b['server_updated_at']! as String,
            );
            return byTime != 0
                ? byTime
                : (a['id']! as String).compareTo(b['id']! as String);
          });
    final page = jsonDecode(jsonEncode(rows.skip(offset).take(limit).toList()));
    return (page as List<Object?>).cast<RemoteRow>();
  }
}
