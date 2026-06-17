import 'package:app/core/services/biometric_service.dart';
import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:app/features/auth/data/services/auth_storage_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final AuthStorageService _storageService;
  final BiometricService _biometricService;

  AuthProvider(
      this._repository, this._storageService, this._biometricService);

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
    final userData = await _storageService.getUserData();
    if (token != null && userData != null) {
      _isLoggedIn = true;
      _userData = userData;
    } else {
      _isLoggedIn = false;
      _userData = null;
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
      AuthRequest(phone: phone, accountType: isLogin ? null : 'individual'),
    );
    setLoading(false);

    debugPrint("--- Initiate Auth Response ---");
    debugPrint("Success: ${response.isSuccess}");
    if (response.isSuccess) {
      debugPrint(
        "Data: ${response.data?.phone}, Needs Onboarding: ${response.data?.needsOnboarding}",
      );
      _userData = response.data;
      if (response.data != null) {
        await _storageService.saveUserData(response.data!);
      }
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
      debugPrint(
        "Data: ${response.data?.phone}, Needs Onboarding: ${response.data?.needsOnboarding}, Token: ${response.data?.token != null}",
      );
      _userData = response.data;
      if (response.data != null) {
        await _storageService.saveUserData(response.data!);
        if (response.data?.phone != null) {
          await _biometricService.saveLastPhone(response.data!.phone!);
        }
        if (response.data?.token != null) {
          _isLoggedIn = true;
          await _storageService.saveTokens(
            token: response.data!.token!,
            refreshToken: response.data!.refreshToken ?? "",
          );
        }
      }
      return true;
    } else {
      _errorMessage = response.error ?? 'Verification failed';
      return false;
    }
  }

  Future<bool> loginWithBiometric() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    if (!isEnabled) {
      _errorMessage = "Biometrics not enabled";
      return false;
    }

    final authenticated = await _biometricService.authenticateLocally();
    if (!authenticated) return false;

    setLoading(true);
    final biometricId = await _biometricService.getBiometricId();
    final phone = await _biometricService.getLastPhone();

    if (biometricId == null || phone == null) {
      setLoading(false);
      _errorMessage = "Biometric data missing. Please login with OTP.";
      return false;
    }

    final response = await _repository.authenticateBiometric(
      BiometricAuthRequest(biometricID: biometricId, phone: phone),
    );
    setLoading(false);

    if (response.isSuccess) {
      _userData = response.data;
      if (response.data != null) {
        await _storageService.saveUserData(response.data!);
        if (response.data?.token != null) {
          _isLoggedIn = true;
          await _storageService.saveTokens(
            token: response.data!.token!,
            refreshToken: response.data!.refreshToken ?? "",
          );
        }
      }
      return true;
    } else {
      _errorMessage = response.error ?? 'Biometric authentication failed';
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
      if (response.data != null) {
        await _storageService.saveUserData(response.data!);
        if (response.data?.token != null) {
          _isLoggedIn = true;
          await _storageService.saveTokens(
            token: response.data!.token!,
            refreshToken: response.data!.refreshToken ?? "",
          );
        }
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
