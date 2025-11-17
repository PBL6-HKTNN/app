import 'package:codemy_app/src/core/validators/password.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Password Validation Tests', () {
    test('should return null for valid passwords', () {
      final validPasswords = [
        'Password123!',
        'MySecure@Pass',
        'StrongP@ssw0rd',
        'Complex#1234',
        r'ValidPass$123',
      ];

      for (final password in validPasswords) {
        final result = validatePassword(password);
        expect(
          result,
          isNull,
          reason: 'Password "$password" should be valid but got error: $result',
        );
      }
    });

    test('should return error for passwords shorter than 8 characters', () {
      final shortPasswords = ['', '1234567', 'Short1!', 'Abc@1'];

      for (final password in shortPasswords) {
        final result = validatePassword(password);
        expect(
          result,
          isNotNull,
          reason: 'Password "$password" should be invalid (too short)',
        );
        expect(
          result,
          contains('8 characters'),
          reason: 'Error message should mention minimum length',
        );
      }
    });

    test('should return error for passwords without uppercase letters', () {
      final noUppercasePasswords = [
        'password123!',
        'lowercase@123',
        r'nouppercase$456',
        'alllower#789',
      ];

      for (final password in noUppercasePasswords) {
        final result = validatePassword(password);
        expect(
          result,
          isNotNull,
          reason: 'Password "$password" should be invalid (no uppercase)',
        );
        expect(
          result,
          contains('uppercase'),
          reason: 'Error message should mention uppercase requirement',
        );
      }
    });

    test('should return error for passwords without special characters', () {
      final noSpecialCharPasswords = [
        'Password123',
        'NoSpecialChar1',
        'UppercaseAnd123',
        'MissingSpecial456',
      ];

      for (final password in noSpecialCharPasswords) {
        final result = validatePassword(password);
        expect(
          result,
          isNotNull,
          reason: 'Password "$password" should be invalid (no special char)',
        );
        expect(
          result,
          contains('special character'),
          reason: 'Error message should mention special character requirement',
        );
      }
    });

    test(
      'should return error for passwords missing both uppercase and special chars',
      () {
        final invalidPasswords = [
          'password123',
          'alllowercase',
          'nouppernorspecial123',
          'justlowerandnumbers456',
        ];

        for (final password in invalidPasswords) {
          final result = validatePassword(password);
          expect(
            result,
            isNotNull,
            reason: 'Password "$password" should be invalid',
          );
          expect(
            result,
            anyOf([contains('uppercase'), contains('special character')]),
            reason: 'Error message should mention missing requirements',
          );
        }
      },
    );

    test('should accept various special characters', () {
      final specialCharPasswords = [
        'Password!123',
        'MyPass@123',
        'Test#Password1',
        r'Secure$Pass123',
        'Valid%Password1',
        'Strong^Pass123',
        'Good&Password1',
        'Nice*Pass123',
        'Cool(Pass)123',
        'Fine+Pass-123',
        'Great.Pass,123',
        'Best?Pass:123',
        'Top"Pass;123',
        'Nice{Pass}123',
        'Good|Pass<123',
        'Cool>Pass123',
      ];

      for (final password in specialCharPasswords) {
        final result = validatePassword(password);
        expect(
          result,
          isNull,
          reason: 'Password "$password" should be valid with special char',
        );
      }
    });

    test('should handle exact minimum requirements', () {
      // Exactly 8 characters with uppercase and special char
      final minimalPasswords = [
        'Password!',
        'MyPass@1',
        'Test#123',
        r'Min$Pass',
      ];

      for (final password in minimalPasswords) {
        final result = validatePassword(password);
        expect(
          result,
          isNull,
          reason: 'Password "$password" meets minimum requirements',
        );
      }
    });
  });
}
