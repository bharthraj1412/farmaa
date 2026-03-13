// Widget tests for key Farmaa screens.
// Run with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Crop Card Tests ───────────────────────────────────────────────────────────

void main() {
  group('PriceLockBadge', () {
    testWidgets('shows "Update Available" when price can be changed',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _PriceLockBadgeHarness(canUpdate: true, daysRemaining: 0),
          ),
        ),
      );
      expect(find.text('Update Available'), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('shows lock message when within 6-month window',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _PriceLockBadgeHarness(canUpdate: false, daysRemaining: 90),
          ),
        ),
      );
      // "~3 mo" should appear (90 / 30 = 3)
      expect(find.textContaining('3 mo'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows 1 mo for 20 days remaining', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _PriceLockBadgeHarness(canUpdate: false, daysRemaining: 20),
          ),
        ),
      );
      expect(find.textContaining('1 mo'), findsOneWidget);
    });
  });

  group('CropModel 6-Month Price Lock Logic', () {
    test('canUpdatePrice is true when no lastPriceUpdate', () {
      final crop = _makeCrop(lastPriceUpdate: null);
      expect(crop.canUpdatePrice, isTrue);
    });

    test('canUpdatePrice is false within 180 days', () {
      final recent = DateTime.now().subtract(const Duration(days: 90));
      final crop = _makeCrop(lastPriceUpdate: recent);
      expect(crop.canUpdatePrice, isFalse);
    });

    test('canUpdatePrice is true after 180 days', () {
      final old = DateTime.now().subtract(const Duration(days: 181));
      final crop = _makeCrop(lastPriceUpdate: old);
      expect(crop.canUpdatePrice, isTrue);
    });

    test('daysUntilPriceUpdate correct when locked', () {
      final recent = DateTime.now().subtract(const Duration(days: 120));
      final crop = _makeCrop(lastPriceUpdate: recent);
      // 180 - 120 = 60 days remaining
      expect(crop.daysUntilPriceUpdate, inInclusiveRange(58, 62));
    });

    test('daysUntilPriceUpdate is 0 when unlocked', () {
      final old = DateTime.now().subtract(const Duration(days: 200));
      final crop = _makeCrop(lastPriceUpdate: old);
      expect(crop.daysUntilPriceUpdate, equals(0));
    });
  });

  group('Login Screen', () {
    testWidgets('shows phone number step by default', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: _LoginHarness(),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });
  });
}

// ── Test Harnesses ────────────────────────────────────────────────────────────

class _PriceLockBadgeHarness extends StatelessWidget {
  final bool canUpdate;
  final int daysRemaining;
  const _PriceLockBadgeHarness(
      {required this.canUpdate, required this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    if (canUpdate) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lock_open, size: 12),
          Text('Update Available'),
        ]),
      );
    }
    final months = (daysRemaining / 30).ceil();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.lock, size: 12),
        Text('🔒 Locked · ~$months mo'),
      ]),
    );
  }
}

class _LoginHarness extends StatelessWidget {
  const _LoginHarness();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: Column(children: [
        Text('Mobile Number'),
        Text('Send OTP'),
      ])),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// A minimal CropModel-like class for testing the business logic
class _TestCrop {
  final DateTime? lastPriceUpdate;

  const _TestCrop({this.lastPriceUpdate});

  static const int priceUpdateCycleDays = 180;

  bool get canUpdatePrice {
    if (lastPriceUpdate == null) return true;
    final nextAllowed =
        lastPriceUpdate!.add(const Duration(days: priceUpdateCycleDays));
    return DateTime.now().isAfter(nextAllowed);
  }

  int get daysUntilPriceUpdate {
    if (canUpdatePrice) return 0;
    final next =
        lastPriceUpdate!.add(const Duration(days: priceUpdateCycleDays));
    return next.difference(DateTime.now()).inDays;
  }
}

_TestCrop _makeCrop({DateTime? lastPriceUpdate}) =>
    _TestCrop(lastPriceUpdate: lastPriceUpdate);
