import 'package:flutter_test/flutter_test.dart';
import 'package:pfaiassistant/core/security/pin_hasher.dart';

void main() {
  group('PinHasher', () {
    test('hash and verify matching pin', () {
      final stored = PinHasher.hashPin('1234');
      expect(PinHasher.verifyPin('1234', stored), isTrue);
    });

    test('reject incorrect pin', () {
      final stored = PinHasher.hashPin('1234');
      expect(PinHasher.verifyPin('9999', stored), isFalse);
    });
  });
}
