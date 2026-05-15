import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _userName;
  String? get userName => _userName;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    setLoading(true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    _isLoggedIn = true;
    _userName = "Emmanuel Bankole";
    setLoading(false);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String dob,
    required String password,
  }) async {
    setLoading(true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    _isLoggedIn = true;
    _userName = name;
    setLoading(false);
  }

  void logout() {
    _isLoggedIn = false;
    _userName = null;
    notifyListeners();
  }
}
