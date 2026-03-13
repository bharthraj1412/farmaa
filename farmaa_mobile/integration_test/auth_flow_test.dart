import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:farmaa_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Login -> OTP -> Dashboard fully works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // We might land on splash, handle it
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Find 'LOGIN' button on onboarding
      final loginBtn = find.text('LOGIN');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn);
        await tester.pumpAndSettle();
      }

      // We should be on LoginScreen, find the phone input
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);

      // Enter phone number
      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.pumpAndSettle();

      // Tap Send OTP
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();
      
      // Wait for server delay and dialog/snackbars
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // We should now be on OtpScreen
      expect(find.text('Enter OTP'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Enter OTP
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      // Wait for server processing and navigation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // We should be redirected to the Buyer Dashboard which has "Hello, " text somewhere
      expect(find.textContaining('Hello,'), findsWidgets);
    });
  });
}
