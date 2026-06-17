import 'dart:convert';
import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  Future<void> saveTokens({required String token, required String refreshToken}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> saveUserData(AuthResponseData userData) async {
    await _storage.write(key: _userKey, value: jsonEncode(userData.toJson()));
  }

  Future<AuthResponseData?> getUserData() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      try {
        return AuthResponseData.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }
}
