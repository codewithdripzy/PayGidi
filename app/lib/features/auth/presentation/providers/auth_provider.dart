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

  PgUser? _userData; // Holds comprehensive user details
  PgUser? get userData => _userData;

  List<Wallet>? _wallets; // Holds user's wallets
  List<Wallet>? get wallets => _wallets;

  AuthResponseData? _authResponseData; // Holds basic auth info (tokens, etc.)
  AuthResponseData? get authResponseData => _authResponseData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> checkLoginStatus() async {
    final token = await _storageService.getToken();
    if (token != null) {
      _isLoggedIn = true;
      _authResponseData = await _storageService.getAuthResponseData();
      _userData = await _storageService.getPgUser();
    } else {
      _isLoggedIn = false;
      _authResponseData = null;
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
      _authResponseData = response.data;
      if (_authResponseData != null) {
        await _storageService.saveAuthResponseData(_authResponseData!);
        if (_authResponseData?.token != null) {
          await _storageService.saveTokens(
            token: _authResponseData!.token!,
            refreshToken: _authResponseData!.refreshToken ?? "",
          );
          _isLoggedIn = true;
        }
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
      _authResponseData = response.data;
      if (_authResponseData != null) {
        await _storageService.saveAuthResponseData(_authResponseData!);
        if (_authResponseData?.phone != null) {
          await _biometricService.saveLastPhone(_authResponseData!.phone!);
        }
        if (_authResponseData?.token != null) {
          debugPrint("--- AuthProvider: New token received: ${response.data!.token} ---");
          _isLoggedIn = true;
          await _storageService.saveTokens(
            token: _authResponseData!.token!,
            refreshToken: _authResponseData!.refreshToken ?? "",
          );
        } else {
          debugPrint("--- AuthProvider: No new token received in response ---");
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
      _authResponseData = response.data;
      if (_authResponseData != null) {
        await _storageService.saveAuthResponseData(_authResponseData!);
        if (_authResponseData?.token != null) {
          debugPrint("--- AuthProvider: New token received: ${response.data!.token} ---");
          _isLoggedIn = true;
          await _storageService.saveTokens(
            token: _authResponseData!.token!,
            refreshToken: _authResponseData!.refreshToken ?? "",
          );
        } else {
          debugPrint("--- AuthProvider: No new token received in response ---");
        }
      }
      return true;
    } else {
      _errorMessage = response.error ?? 'Biometric authentication failed';
      return false;
    }
  }

  Future<bool> fetchAndSetCurrentUser() async {
    final response = await _repository.fetchCurrentUser(); // Now returns ApiResponse<AccountResponse>

    if (response.isSuccess && response.data != null) {
      _userData = response.data!.data.user;
      _wallets = response.data!.data.wallets;
      _isLoggedIn = true; // Ensure isLoggedIn is true if user data is fetched successfully
      await _storageService.savePgUser(_userData!);
      notifyListeners();
      return true;
    } else {
      _isLoggedIn = false;
      _userData = null;
      _wallets = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeIndividualAccount(
    IndividualCompleteAccountRequest request,
  ) async {
    setLoading(true);
    final response = await _repository.completeIndividualAccount(
      request,
      token: _authResponseData?.token, // Use _authResponseData for token
    );
    setLoading(false);

    if (response.isSuccess) {
      _authResponseData = response.data;
      if (_authResponseData != null) {
        await _storageService.saveAuthResponseData(_authResponseData!);
        if (_authResponseData?.token != null) {
          debugPrint("--- AuthProvider: New token received: ${response.data!.token} ---");
          _isLoggedIn = true;
          await _storageService.saveTokens(
            token: _authResponseData!.token!,
            refreshToken: _authResponseData!.refreshToken ?? "",
          );
        } else {
          debugPrint("--- AuthProvider: No new token received in response ---");
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
    _wallets = null;
    _authResponseData = null;
    _storageService.clearAllAuthData();
    notifyListeners();
  }
}
