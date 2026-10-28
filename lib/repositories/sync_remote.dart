/// Linha de uma tabela no formato do servidor: colunas em snake_case e
/// valores JSON (datas como texto ISO 8601).
typedef RemoteRow = Map<String, Object?>;

/// Servidor da sincronização. Falhas saem como `SyncFailure`.
abstract interface class SyncRemote {
  /// Envia as linhas alteradas, por tabela, numa transação só. Reenviar o
  /// mesmo pacote não duplica nada, e uma linha só substitui a do servidor
  /// se tiver `updated_at` maior.
  Future<void> push(Map<String, List<RemoteRow>> changes);

  /// Linhas de [table] do dono [ownerId] gravadas no servidor depois de
  /// [since], em ordem de `server_updated_at` e `id`.
  Future<List<RemoteRow>> pull(
    String table, {
    required String ownerColumn,
    required String ownerId,
    required DateTime since,
    required int offset,
    required int limit,
  });
}
