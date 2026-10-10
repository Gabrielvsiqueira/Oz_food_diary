import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/session_user.dart';
import '../repositories/session_repository.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._repository) {
    _revoked = _repository.sessionRevoked.listen((_) => _onRevoked());
  }

  final SessionRepository _repository;
  late final StreamSubscription<void> _revoked;

  SessionUser? _user;
  bool _wasRevoked = false;

  SessionUser? get user => _user;

  bool get isAuthenticated => _user != null;

  /// Se a sessão foi encerrada pelo servidor; a UI volta para o início.
  bool get wasRevoked => _wasRevoked;

  /// Retoma a sessão salva ao abrir o app, sem precisar de internet.
  Future<bool> restore() async {
    _user = await _repository.currentUser();
    notifyListeners();
    return isAuthenticated;
  }

  Future<void> login({required String email, required String password}) =>
      _start(() => _repository.signIn(email: email, password: password));

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) => _start(
    () => _repository.signUp(email: email, password: password, name: name),
  );

  Future<void> loginWithGoogle() => _start(_repository.signInWithGoogle);

  Future<void> logout() async {
    await _repository.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _repository.deleteAccount();
    _user = null;
    notifyListeners();
  }

  Future<void> _start(Future<SessionUser> Function() signIn) async {
    _user = await signIn();
    _wasRevoked = false;
    notifyListeners();
  }

  Future<void> _onRevoked() async {
    if (!isAuthenticated) return;
    await _repository.signOut();
    _user = null;
    _wasRevoked = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _revoked.cancel();
    super.dispose();
  }
}
