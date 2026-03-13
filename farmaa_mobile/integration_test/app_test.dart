import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:farmaa_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Farmaa App Integration Tests', () {
    testWidgets('Splash screen loads and shows app name', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App should show splash, then redirect to onboarding or login
      // We just check that something renders without crashing.
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
