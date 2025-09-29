import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _authenticatedUser;

  String? get authenticatedUser => _authenticatedUser;

  bool get isAuthenticated => _authenticatedUser != null;

  void login(String username) {
    _authenticatedUser = username;
    notifyListeners();
  }

  void logout() {
    _authenticatedUser = null;
    notifyListeners();
  }
}
