import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:app/features/auth/data/services/auth_storage_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final AuthStorageService _storageService;

  AuthProvider(this._repository, this._storageService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  AuthResponseData? _userData;
  AuthResponseData? get userData => _userData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> checkLoginStatus() async {
    final token = await _storageService.getToken();
    if (token != null) {
      _isLoggedIn = true;
      // Ideally fetch user data here too
    }
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> initiateIndividualAuth({
    required String phone,
    String? accountType,
    bool isLogin = true,
  }) async {
    setLoading(true);
    final response = await _repository.initiateAuth(
      AuthRequest(
        phone: phone,
        accountType: accountType,
      ),
    );
    setLoading(false);

    debugPrint("--- Initiate Auth Response ---");
    debugPrint("Success: ${response.isSuccess}");
    if (response.isSuccess) {
      debugPrint("Data: ${response.data?.phone}, Needs Onboarding: ${response.data?.needsOnboarding}");
      _userData = response.data;
      return true;
    } else {
      debugPrint("Error: ${response.error}");
      _errorMessage = response.error ?? 'Authentication failed';
      return false;
    }
  }

  Future<bool> verifyOtp({required String phone, required String code}) async {
    setLoading(true);
    final response = await _repository.verifyOTP(
      VerifyOtpRequest(phone: phone, code: code),
    );
    setLoading(false);

    debugPrint("--- Verify OTP Response ---");
    debugPrint("Success: ${response.isSuccess}");
    if (response.isSuccess) {
      debugPrint("Data: ${response.data?.phone}, Needs Onboarding: ${response.data?.needsOnboarding}, Token: ${response.data?.token != null}");
      _userData = response.data;
      if (response.data?.token != null) {
        _isLoggedIn = true;
        await _storageService.saveTokens(
          token: response.data!.token!,
          refreshToken: response.data!.refreshToken ?? "",
        );
      }
      return true;
    } else {
      _errorMessage = response.error ?? 'Verification failed';
      return false;
    }
  }

  Future<bool> completeIndividualAccount(
    IndividualCompleteAccountRequest request,
  ) async {
    setLoading(true);
    final response = await _repository.completeIndividualAccount(
      request,
      token: _userData?.token,
    );
    setLoading(false);

    if (response.isSuccess) {
      _userData = response.data;
      if (response.data?.token != null) {
        _isLoggedIn = true;
        await _storageService.saveTokens(
          token: response.data!.token!,
          refreshToken: response.data!.refreshToken ?? "",
        );
      }
      return true;
    } else {
      _errorMessage = response.error ?? 'Failed to complete account';
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _userData = null;
    _storageService.clearTokens();
    notifyListeners();
  }
}
