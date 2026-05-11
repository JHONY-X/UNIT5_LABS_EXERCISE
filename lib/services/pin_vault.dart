import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinVault {
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'app_pin';

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin == pin;
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }
}
