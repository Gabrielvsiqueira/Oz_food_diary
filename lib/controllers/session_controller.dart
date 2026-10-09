import 'package:flutter/foundation.dart';

import '../repositories/session_repository.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._repository);

  final SessionRepository _repository;

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  /// Retoma a sessão salva ao abrir o app, sem precisar de internet.
  Future<bool> restore() async {
    _isAuthenticated = await _repository.hasSession();
    notifyListeners();
    return _isAuthenticated;
  }

  void startSession() {
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    await _repository.signIn(email: email, password: password);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.signOut();
    _isAuthenticated = false;
    notifyListeners();
  }
}
