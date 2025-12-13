import 'package:codemy_app/l10n/app_localizations.dart';
import 'package:codemy_app/src/core/validators/index.dart';
import 'package:codemy_app/src/features/user/widgets/auth/login_form.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  group('LoginForm Validation Tests', () {
    late material.Widget testApp;

    setUp(() {
      testApp = ProviderScope(
        child: shadcn.ShadcnApp(
          home: shadcn.Scaffold(
            child: material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: const LoginForm(),
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

      // Find email field and login button
      final emailField = find.byType(shadcn.TextField).first;
      final loginButton = find.text('Login');

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.enterText(find.byType(shadcn.TextField).last, 'password123');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.textContaining('valid email'), findsOneWidget);
    });

    testWidgets('displays password validation errors', (tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Find fields and button
      final emailField = find.byType(shadcn.TextField).first;
      final passwordField = find.byType(shadcn.TextField).last;
      final loginButton = find.text('Login');

      // Enter valid email but empty password
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show password validation error
      expect(find.textContaining('required'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.byType(shadcn.TextField).last;
      await tester.enterText(passwordField, 'secretpassword');

      // Find visibility toggle button
      final visibilityButton = find.byIcon(material.Icons.visibility);
      expect(visibilityButton, findsOneWidget);

      // Tap to toggle visibility
      await tester.tap(visibilityButton);
      await tester.pumpAndSettle();

      // Should now show visibility_off icon
      expect(find.byIcon(material.Icons.visibility_off), findsOneWidget);
    });

    testWidgets('accepts valid email and password', (tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(
        find.byType(shadcn.TextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).last,
        'validpassword',
      );

      // Should not show validation errors when fields are valid
      expect(find.textContaining('valid email'), findsNothing);
      expect(find.textContaining('required'), findsNothing);
    });
  });

  group('Email Validation Unit Tests', () {
    test('validateEmail returns null for valid emails', () {
      expect(validateEmail('test@example.com'), isNull);
      expect(validateEmail('user.name@domain.co.uk'), isNull);
      expect(validateEmail('123@test.org'), isNull);
    });

    test('validateEmail returns error for invalid emails', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('invalid-email'), isNotNull);
      expect(validateEmail('@domain.com'), isNotNull);
      expect(validateEmail('test@'), isNotNull);
      expect(validateEmail('test.domain.com'), isNotNull);
    });

    test('validateEmail handles edge cases', () {
      expect(validateEmail('   '), isNotNull); // whitespace only
      expect(validateEmail('test@domain'), isNotNull); // no TLD
      expect(validateEmail('test..test@domain.com'), isNotNull); // double dots
    });
  });
}
