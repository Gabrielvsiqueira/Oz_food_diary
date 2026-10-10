import '../models/session_user.dart';

/// Autenticação do usuário. Os métodos lançam `AuthFailure`.
abstract interface class SessionRepository {
  /// Usuário com sessão salva neste aparelho, mesmo sem internet.
  Future<SessionUser?> currentUser();

  /// Emite quando o servidor encerra a sessão (ex.: senha trocada em outro
  /// aparelho ou conta excluída), sem o usuário ter pedido para sair.
  Stream<void> get sessionRevoked;

  Future<SessionUser> signIn({required String email, required String password});

  Future<SessionUser> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<SessionUser> signInWithGoogle();

  /// Encerra a sessão e apaga os dados do usuário deste aparelho.
  Future<void> signOut();

  /// Exclui a conta e todos os dados, no servidor e no aparelho.
  Future<void> deleteAccount();
}
