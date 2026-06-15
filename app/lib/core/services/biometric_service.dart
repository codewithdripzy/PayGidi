import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _biometricIdKey = 'biometric_id';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastUsedPhoneKey = 'last_used_phone';

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticateLocally() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access your PayGidi account',
      );
    } catch (e) {
      return false;
    }
  }

  Future<String?> getBiometricId() async {
    return await _storage.read(key: _biometricIdKey);
  }

  Future<String> generateAndStoreBiometricId() async {
    final String biometricId = const Uuid().v4();
    await _storage.write(key: _biometricIdKey, value: biometricId);
    return biometricId;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final String? enabled = await _storage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  Future<void> clearBiometricData() async {
    await _storage.delete(key: _biometricIdKey);
    await _storage.delete(key: _biometricEnabledKey);
    await _storage.delete(key: _lastUsedPhoneKey);
  }

  Future<void> saveLastPhone(String phone) async {
    await _storage.write(key: _lastUsedPhoneKey, value: phone);
  }

  Future<String?> getLastPhone() async {
    return await _storage.read(key: _lastUsedPhoneKey);
  }
}
