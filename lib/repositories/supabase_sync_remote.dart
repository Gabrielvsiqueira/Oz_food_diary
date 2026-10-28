import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sync_failure.dart';
import 'sync_remote.dart';

/// Sincronização pelo Supabase: envio pela função `push_changes` e
/// download direto das tabelas (a RLS limita ao que o usuário pode ler).
class SupabaseSyncRemote implements SyncRemote {
  const SupabaseSyncRemote(
    this._client, {
    this.timeout = const Duration(seconds: 20),
  });

  final SupabaseClient _client;
  final Duration timeout;

  @override
  Future<void> push(Map<String, List<RemoteRow>> changes) => _guard(
    () => _client.rpc<void>('push_changes', params: {'changes': changes}),
  );

  @override
  Future<List<RemoteRow>> pull(
    String table, {
    required String ownerColumn,
    required String ownerId,
    required DateTime since,
    required int offset,
    required int limit,
  }) => _guard(
    () => _client
        .from(table)
        .select()
        .eq(ownerColumn, ownerId)
        .gt('server_updated_at', since.toUtc().toIso8601String())
        .order('server_updated_at', ascending: true)
        .order('id', ascending: true)
        .range(offset, offset + limit - 1),
  );

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request().timeout(timeout);
    } on SocketException {
      throw const SyncOfflineFailure();
    } on ClientException {
      throw const SyncOfflineFailure();
    } on TimeoutException {
      throw const SyncOfflineFailure();
    } on AuthRetryableFetchException {
      throw const SyncOfflineFailure();
    } on PostgrestException catch (e) {
      throw SyncServerFailure(e);
    } on AuthException catch (e) {
      throw SyncServerFailure(e);
    }
  }
}
