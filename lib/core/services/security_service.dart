import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();
  final String _pinKey = "user_secure_pin";


  //To check if user registered or not
  Future<bool> isRegistered() async {
    String? pin = await _storage.read(key: _pinKey);
    return pin != null;
  }

  // To Save Pin
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  //To verify pin
  Future<bool> verifyPin(String enteredPin) async {
    String? savedPin = await _storage.read(key: _pinKey);
    return savedPin == enteredPin;
  }

  //Fingerprint Login
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(biometricOnly: false),
      );
    } catch (e) {
      return false;
    }
  }
}