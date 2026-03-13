import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Shown after a successful Razorpay payment.
class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final String cropName;
  final double quantity;
  final double totalAmount;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.cropName,
    required this.quantity,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success animation-like container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.elevatedShadow,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  l.orderPlaced,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  l.orderConfirmed,
                  style:
                      const TextStyle(color: AppTheme.textMedium, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Order summary card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.radiusLarge,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(Icons.tag, l.orderId, orderId),
                      const SizedBox(height: 12),
                      _row(Icons.agriculture_outlined, l.crop, cropName),
                      const SizedBox(height: 12),
                      _row(Icons.scale_outlined, l.quantity,
                          '${quantity.toStringAsFixed(1)} kg'),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee,
                              size: 18, color: AppTheme.primaryGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(l.amountPaid,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark)),
                          ),
                          Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Track order
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.buyerOrders),
                    icon: const Icon(Icons.track_changes_outlined),
                    label: Text(l.trackOrder),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.buyerHome),
                    icon: const Icon(Icons.storefront_outlined),
                    label: Text(l.continueShopping),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child:
                Text(label, style: const TextStyle(color: AppTheme.textMedium)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      );
}
