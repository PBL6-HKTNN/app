import 'package:codemy_app/src/core/validators/email.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email Validation Tests', () {
    test('should return null for valid email addresses', () {
      final validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user_tag@example.org',
        'firstname.lastname@company.com',
        'user123@test-domain.com',
      ];

      for (final email in validEmails) {
        final result = validateEmail(email);
        expect(
          result,
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
        // When input is exactly empty we expect the exact 'Email is required' message
        if (email.isEmpty) {
          expect(
            result,
            'Email is required',
            reason: 'Empty email should return required message',
          );
        } else {
          expect(
            result,
            'Please enter a valid email address',
            reason: 'Email "$email" should be invalid',
          );
        }
      }
    });

    test('should handle null input', () {
      final result = validateEmail(null);
      expect(result, 'Email is required');
    });

    test('should handle empty string', () {
      final result = validateEmail('');
      expect(result, 'Email is required');
    });

    test('should handle whitespace-only string', () {
      final result = validateEmail('   ');
      expect(result, 'Please enter a valid email address');
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
        expect(
          result,
          'Please enter a valid email address',
          reason: 'Email "$email" should be invalid',
        );
      }
    });
  });
}
