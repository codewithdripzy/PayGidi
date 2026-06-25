import 'dart:convert';
import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _authResponseDataKey = 'auth_response_data';
  static const _pgUserKey = 'pg_user_data';
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

  Future<void> saveTokens({required String token, required String refreshToken}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveAuthResponseData(AuthResponseData authResponseData) async {
    await _storage.write(key: _authResponseDataKey, value: jsonEncode(authResponseData.toJson()));
  }

  Future<AuthResponseData?> getAuthResponseData() async {
    final authResponseJson = await _storage.read(key: _authResponseDataKey);
    if (authResponseJson != null) {
      try {
        return AuthResponseData.fromJson(jsonDecode(authResponseJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> savePgUser(PgUser pgUser) async {
    await _storage.write(key: _pgUserKey, value: jsonEncode(pgUser.toJson()));
  }

  Future<PgUser?> getPgUser() async {
    final pgUserJson = await _storage.read(key: _pgUserKey);
    if (pgUserJson != null) {
      try {
        return PgUser.fromJson(jsonDecode(pgUserJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<bool> getHasSeenOnboarding() async {
    final value = await _storage.read(key: _hasSeenOnboardingKey);
    return value == 'true';
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await _storage.write(key: _hasSeenOnboardingKey, value: value.toString());
  }

  Future<void> clearAllAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _authResponseDataKey);
    await _storage.delete(key: _pgUserKey);
  }
}
