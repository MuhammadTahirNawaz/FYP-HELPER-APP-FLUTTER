import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_helper_app/core/validators.dart';

void main() {
  group('AppValidators.email', () {
    test('accepts valid email', () {
      expect(AppValidators.email('student@uet.edu.pk'), isNull);
    });

    test('rejects invalid email', () {
      expect(AppValidators.email('not-an-email'), isNotNull);
    });
  });

  group('AppValidators.pakistaniPhone', () {
    test('accepts 03xx format', () {
      expect(AppValidators.pakistaniPhone('03001234567'), isNull);
    });

    test('accepts +92 format', () {
      expect(AppValidators.pakistaniPhone('+923001234567'), isNull);
    });

    test('rejects invalid number', () {
      expect(AppValidators.pakistaniPhone('12345'), isNotNull);
    });
  });

  group('AppValidators.required', () {
    test('rejects empty values', () {
      expect(AppValidators.required('  '), isNotNull);
    });
  });
}
