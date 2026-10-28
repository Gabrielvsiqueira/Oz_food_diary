/// Falhas da sincronização, independentes do servidor. A mensagem exibida
/// fica na camada de View (`string_extensions.dart`).
sealed class SyncFailure implements Exception {
  const SyncFailure();
}

/// Sem internet ou servidor fora do ar; os dados seguem salvos no aparelho.
class SyncOfflineFailure extends SyncFailure {
  const SyncOfflineFailure();
}

class SyncServerFailure extends SyncFailure {
  const SyncServerFailure([this.cause]);
  final Object? cause;

  @override
  String toString() => 'SyncServerFailure($cause)';
}
