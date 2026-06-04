import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pfaiassistant/core/security/pin_hasher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  SecurityService({FlutterSecureStorage? storage, LocalAuthentication? auth})
    : _storage = storage ?? const FlutterSecureStorage(),
      _auth = auth ?? LocalAuthentication();

  final FlutterSecureStorage _storage;
  final LocalAuthentication _auth;

  static const _pinKey = 'user_secure_pin';
  static const _failedAttemptsKey = 'pin_failed_attempts';
  static const _lockUntilKey = 'pin_lock_until_ms';
  static const _maxAttempts = 5;
  static const _lockoutDuration = Duration(seconds: 30);

  Future<bool> isRegistered() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null;
  }

  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: PinHasher.hashPin(pin));
    await _resetLockout();
  }

  Future<PinVerificationResult> verifyPin(String enteredPin) async {
    final lockMessage = await _lockoutMessage();
    if (lockMessage != null) {
      return PinVerificationResult.locked(lockMessage);
    }

    final savedPin = await _storage.read(key: _pinKey);
    if (savedPin == null) {
      return PinVerificationResult.invalid(
        'No PIN found. Please register again.',
      );
    }

    final isValid = _verifyStoredPin(enteredPin, savedPin);
    if (isValid) {
      await _resetLockout();
      return PinVerificationResult.success();
    }

    return _registerFailedAttempt();
  }

  bool _verifyStoredPin(String enteredPin, String savedPin) {
    if (savedPin.contains(':')) {
      return PinHasher.verifyPin(enteredPin, savedPin);
    }

    // Legacy plaintext PIN support — re-hash on successful login elsewhere if needed.
    return savedPin == enteredPin;
  }

  Future<PinVerificationResult> _registerFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt(_failedAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_failedAttemptsKey, attempts);

    if (attempts >= _maxAttempts) {
      final lockUntil = DateTime.now()
          .add(_lockoutDuration)
          .millisecondsSinceEpoch;
      await prefs.setInt(_lockUntilKey, lockUntil);
      await prefs.setInt(_failedAttemptsKey, 0);
      return PinVerificationResult.locked(
        'Too many failed attempts. Try again in ${_lockoutDuration.inSeconds} seconds.',
      );
    }

    final remaining = _maxAttempts - attempts;
    return PinVerificationResult.invalid(
      'Incorrect PIN. $remaining attempts left.',
    );
  }

  Future<String?> _lockoutMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final lockUntilMs = prefs.getInt(_lockUntilKey);
    if (lockUntilMs == null) return null;

    final lockUntil = DateTime.fromMillisecondsSinceEpoch(lockUntilMs);
    if (DateTime.now().isBefore(lockUntil)) {
      final seconds = lockUntil
          .difference(DateTime.now())
          .inSeconds
          .clamp(1, 999);
      return 'Too many failed attempts. Try again in $seconds seconds.';
    }

    await prefs.remove(_lockUntilKey);
    return null;
  }

  Future<void> _resetLockout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_failedAttemptsKey);
    await prefs.remove(_lockUntilKey);
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return false;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(biometricOnly: false),
      );
    } catch (_) {
      return false;
    }
  }
}

class PinVerificationResult {
  const PinVerificationResult._({
    required this.isSuccess,
    required this.isLocked,
    this.message,
  });

  factory PinVerificationResult.success() {
    return const PinVerificationResult._(isSuccess: true, isLocked: false);
  }

  factory PinVerificationResult.invalid(String message) {
    return PinVerificationResult._(
      isSuccess: false,
      isLocked: false,
      message: message,
    );
  }

  factory PinVerificationResult.locked(String message) {
    return PinVerificationResult._(
      isSuccess: false,
      isLocked: true,
      message: message,
    );
  }

  final bool isSuccess;
  final bool isLocked;
  final String? message;
}
