import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PinHasher {
  static String hashPin(String pin) {
    final salt = _generateSalt();
    final hash = _hashWithSalt(pin, salt);
    return '$salt:$hash';
  }

  static bool verifyPin(String pin, String storedValue) {
    final parts = storedValue.split(':');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final expectedHash = parts[1];
    return _hashWithSalt(pin, salt) == expectedHash;
  }

  static String _hashWithSalt(String pin, String salt) {
    final bytes = utf8.encode('$salt$pin');
    return sha256.convert(bytes).toString();
  }

  static String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }
}
