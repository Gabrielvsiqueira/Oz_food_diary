import 'package:flutter/foundation.dart';

/// Sessão do usuário. Na Fase 1 não há backend: o login aceita qualquer
/// e-mail/senha já validados e o logout só encerra a sessão, mantendo
/// perfil, metas e refeições em memória. Na Fase 3 a implementação troca
/// por autenticação real sem mudar esta interface.
class SessionController extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  /// Marca a sessão como aberta após criar a conta no onboarding.
  void startSession() {
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
