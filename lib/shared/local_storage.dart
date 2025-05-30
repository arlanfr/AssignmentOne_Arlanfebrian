import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  final _storage = FlutterSecureStorage();

  Future<void> setBiometricActive(bool value) async {
    await _storage.write(key: 'biometric status', value: value.toString());
  }

  Future<bool> getBiometricActive() async {
    final value = await _storage.read(key: 'biometric status');
    if (value == null) return false;
    return bool.parse(value);
  }

  Future<void> setUserPassword(String value) async {
    await _storage.write(key: 'user_password', value: value);
  }

  Future<String?> getUserPassword() async {
    return _storage.read(key: 'user_password');
  }
}
