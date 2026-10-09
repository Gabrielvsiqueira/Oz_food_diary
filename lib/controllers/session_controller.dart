import 'package:flutter/foundation.dart';

class SessionController extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

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
