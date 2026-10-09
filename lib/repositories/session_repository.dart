abstract interface class SessionRepository {
  /// Se há um usuário logado neste aparelho, mesmo sem internet.
  Future<bool> hasSession();

  Future<void> signIn({required String email, required String password});

  /// Encerra a sessão e apaga os dados do usuário deste aparelho.
  Future<void> signOut();
}
