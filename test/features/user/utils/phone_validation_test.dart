import 'package:codemy_app/src/core/validators/phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phone Validation Tests', () {
    test('should return null for valid local phone numbers', () {
      final validPhones = [
        '0912345678', // typical mobile
        '0398765432', // 03x number
        '0987654321', // 09x number
        '0321234567', // 03x number
        '0701234567', // 07x number
      ];

      for (final phone in validPhones) {
        final result = validatePhone(phone);
        expect(result, isNull, reason: 'Phone "$phone" should be valid');
      }
    });

    test(
      'should accept formatted phone numbers with spaces, dashes, parentheses',
      () {
        final formattedPhones = [
          '091 234 5678',
          '091-234-5678',
          '(091) 234-5678',
          '091.234.5678',
        ];

        for (final phone in formattedPhones) {
          final result = validatePhone(phone);
          expect(
            result,
            isNull,
            reason: 'Phone "$phone" should be valid after cleaning',
          );
        }
      },
    );

    test('should accept international +84 prefix (after cleaning)', () {
      final internationalPhones = [
        '+84912345678',
        '+84 912 345 678',
        '+84-912-345-678',
      ];

      for (final phone in internationalPhones) {
        final result = validatePhone(phone);
        expect(
          result,
          isNull,
          reason: 'Phone "$phone" should be valid with +84',
        );
      }
    });

    test('should return error for invalid phone numbers', () {
      final invalidPhones = [
        '',
        '12345',
        '+8412345',
        '009112345678',
        '0123456789', // 01x not in valid range
        '0201234567',
        '091234567', // too short
        '09123456789', // too long
        'abcdefghij',
      ];

      for (final phone in invalidPhones) {
        final result = validatePhone(phone);
        expect(result, isNotNull, reason: 'Phone "$phone" should be invalid');
      }
    });

    test('should handle null input and whitespace-only input', () {
      expect(validatePhone(null), isNotNull);
      expect(validatePhone('   '), isNotNull);
    });
  });
}
