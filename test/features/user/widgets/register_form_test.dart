import 'package:codemy_app/l10n/app_localizations.dart';
import 'package:codemy_app/src/core/validators/password.dart';
import 'package:codemy_app/src/features/user/widgets/auth/register_form.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  group('RegisterForm Validation Tests', () {
    late material.Widget testApp;

    setUp(() {
      testApp = ProviderScope(
        child: shadcn.ShadcnApp(
          home: shadcn.Scaffold(
            child: material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: const RegisterForm(),
            ),
          ),
          theme: shadcn.ThemeData(
            colorScheme: shadcn.ColorSchemes.lightDefaultColor,
            radius: 0.5,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    });

    testWidgets('displays email validation errors', (tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Find fields
      final emailField = find.byType(shadcn.TextField).at(0);
      final passwordField = find.byType(shadcn.TextField).at(1);
      final confirmPasswordField = find.byType(shadcn.TextField).at(2);
      final registerButton = find.text('Register');

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.enterText(passwordField, 'ValidPass123!');
      await tester.enterText(confirmPasswordField, 'ValidPass123!');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.textContaining('valid email'), findsOneWidget);
    });

    testWidgets('displays password validation errors', (tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Find fields
      final emailField = find.byType(shadcn.TextField).at(0);
      final passwordField = find.byType(shadcn.TextField).at(1);
      final confirmPasswordField = find.byType(shadcn.TextField).at(2);
      final registerButton = find.text('Register');

      // Enter valid email but weak password
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');
      await tester.enterText(confirmPasswordField, '123');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Should show password validation error
      expect(find.textContaining('8 characters'), findsOneWidget);
    });

    testWidgets('displays password mismatch error', (tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Find fields
      final emailField = find.byType(shadcn.TextField).at(0);
      final passwordField = find.byType(shadcn.TextField).at(1);
      final confirmPasswordField = find.byType(shadcn.TextField).at(2);
      final registerButton = find.text('Register');

      // Enter valid email and password but mismatched confirmation
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'ValidPass123!');
      await tester.enterText(confirmPasswordField, 'DifferentPass123!');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Should show password mismatch error
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('toggles password visibility for both fields', (tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Find password fields
      final passwordField = find.byType(shadcn.TextField).at(1);
      final confirmPasswordField = find.byType(shadcn.TextField).at(2);

      await tester.enterText(passwordField, 'secretpassword');
      await tester.enterText(confirmPasswordField, 'secretpassword');

      // Find visibility toggle buttons
      final visibilityButtons = find.byIcon(material.Icons.visibility);
      expect(visibilityButtons, findsNWidgets(2));

      // Tap first visibility button
      await tester.tap(visibilityButtons.first);
      await tester.pumpAndSettle();

      // Should show one visibility_off icon
      expect(find.byIcon(material.Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(material.Icons.visibility), findsOneWidget);
    });

    testWidgets('accepts valid registration data', (tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Enter all valid data
      await tester.enterText(
        find.byType(shadcn.TextField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(1),
        'ValidPass123!',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(2),
        'ValidPass123!',
      );

      // Should not show validation errors when fields are valid
      expect(find.textContaining('valid email'), findsNothing);
      expect(find.textContaining('8 characters'), findsNothing);
      expect(find.text('Passwords do not match'), findsNothing);
    });
  });

  group('Password Validation Unit Tests', () {
    test('validatePassword returns null for valid passwords', () {
      expect(validatePassword('ValidPass123!'), isNull);
      expect(validatePassword('MySecure@Pass1'), isNull);
      expect(validatePassword('Abcdefgh1!'), isNull);
    });

    test('validatePassword returns error for invalid passwords', () {
      expect(validatePassword(''), isNotNull); // empty
      expect(validatePassword('short'), isNotNull); // too short
      expect(validatePassword('nouppercase123!'), isNotNull); // no uppercase
      expect(validatePassword('NOLOWERCASE123!'), isNotNull); // no lowercase
      expect(validatePassword('NoNumber!'), isNotNull); // no number
      expect(
        validatePassword('NoSpecialChar123'),
        isNotNull,
      ); // no special char
    });

    test('validatePassword handles edge cases', () {
      expect(validatePassword('        '), isNotNull); // whitespace only
      expect(validatePassword('1234567890'), isNotNull); // numbers only
      expect(validatePassword('abcdefghijk'), isNotNull); // lowercase only
    });
  });
}
