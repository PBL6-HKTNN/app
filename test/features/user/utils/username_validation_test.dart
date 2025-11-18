import 'package:codemy_app/src/core/validators/username.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Username Validation Tests', () {
    test('should return null for valid usernames', () {
      final validUsernames = [
        'john',
        'user123',
        'Jane_Doe',
        'name-with-dash',
        'A1_b2',
        'abcdefghijklmnopqrstuvwxyz'.substring(0, 20),
      ];

      for (final username in validUsernames) {
        final result = validateUsername(username);
        expect(result, isNull, reason: 'Username "$username" should be valid');
      }
    });

    test('should return error for null or empty username', () {
      expect(validateUsername(null), isNotNull);
      expect(validateUsername(''), isNotNull);
    });
    test('should return error for null or empty username', () {
      expect(validateUsername(null), 'Username is required');
      expect(validateUsername(''), 'Username is required');
    });

    test('should return error for username shorter than 3 characters', () {
      final shortUsernames = ['a', 'ab'];

      for (final username in shortUsernames) {
        final result = validateUsername(username);
        expect(
          result,
          isNotNull,
          reason: 'Username "$username" should be invalid (too short)',
        );
        expect(
          result,
          'Username must be at least 3 characters long',
          reason: 'Error message should mention min length',
        );
      }
    });

    test('should return error for username longer than 20 characters', () {
      final longUsername = 'a' * 21;
      final result = validateUsername(longUsername);
      expect(result, isNotNull);
      expect(
        result,
        'Username must be no more than 20 characters long',
        reason: 'Error should mention max length',
      );
    });

    test('should return error for invalid characters', () {
      final invalidUsernames = [
        'user name',
        'name!',
        'name@',
        'name#',
        'user*',
        'user%',
      ];

      for (final username in invalidUsernames) {
        final result = validateUsername(username);
        expect(
          result,
          isNotNull,
          reason: 'Username "$username" should be invalid (special chars)',
        );
        expect(
          result,
          'Username can only contain letters, numbers, underscores, and dashes',
          reason: 'Error should mention allowed chars',
        );
      }
    });
  });
}
