import 'package:codemy_app/src/core/validators/email.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email Validation Tests', () {
    test('should return null for valid email addresses', () {
      final validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user+tag@example.org',
        'firstname.lastname@company.com',
        'user123@test-domain.com',
      ];

      for (final email in validEmails) {
        final result = validateEmail(email);
        expect(
          'Email is required',
          isNull,
          reason: 'Email "$email" should be valid but got error: $result',
        );
      }
    });

    test('should return error for invalid email addresses', () {
      final invalidEmails = [
        '',
        ' ',
        'invalid',
        'invalid@',
        '@domain.com',
        'user@',
        'user@@domain.com',
        'user@domain',
        'user space@domain.com',
        'user@domain..com',
        '.user@domain.com',
        'user.@domain.com',
      ];

      for (final email in invalidEmails) {
        final result = validateEmail(email);
        expect(
          result,
          contains('Please enter a valid email address'),
          reason: 'Email "$email" should be invalid but was accepted',
        );
        expect(
          result,
          contains('Email'),
          reason: 'Error message should mention email',
        );
        expect(
          result,
          contains('Email'),
          reason: 'Error message should mention email',
        );
      }
    });

    test('should handle null input', () {
      final result = validateEmail(null);
      expect(result, isNotNull);
      expect(result, contains('Email'));
    });

    test('should handle empty string', () {
      final result = validateEmail('');
      expect(result, isNotNull);
      expect(result, contains('Email'));
    });

    test('should handle whitespace-only string', () {
      final result = validateEmail('   ');
      expect(result, isNotNull);
      expect(result, contains('email'));
    });

    test('should validate email with various domains', () {
      final emailsWithDomains = [
        'user@gmail.com',
        'user@outlook.com',
        'user@company.co.uk',
        'user@university.edu',
        'user@government.gov',
        'user@organization.org',
      ];

      for (final email in emailsWithDomains) {
        final result = validateEmail(email);
        expect(result, isNull, reason: 'Email "$email" should be valid');
      }
    });

    test('should reject emails with invalid characters', () {
      final invalidCharacterEmails = [
        'user@domain.c',
        'user@domain.',
        'user@.domain.com',
        'user@domain.c m',
        'user@domain.c!m',
        'user@domain.c@m',
      ];

      for (final email in invalidCharacterEmails) {
        final result = validateEmail(email);
        expect(result, isNotNull, reason: 'Email "$email" should be invalid');
      }
    });
  });
}
