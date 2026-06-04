import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDatasource {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _pinKey = "user_pin";

  Future<void> savedPin(String pin) async => await _storage.write(key: _pinKey, value: pin);
  Future<String?> getPin() async => await _storage.read(key: _pinKey);
  Future<bool> hasPin() async => await _storage.containsKey(key: _pinKey);
}