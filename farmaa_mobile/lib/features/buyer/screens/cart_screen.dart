import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.cart),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartNotifierProvider.notifier).clear(),
              child: Text(l.remove,
                  style: const TextStyle(color: AppTheme.errorRed)),
            ),
        ],
      ),
      backgroundColor: AppTheme.surfaceCream,
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(l.cartEmpty,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    l.cartEmptyHint,
                    style: const TextStyle(color: AppTheme.textLight),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.buyerHome),
                    child: Text(l.browseGrains),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) => _CartItemTile(item: items[i]),
                  ),
                ),
                _CheckoutBar(total: total),
              ],
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    final crop = item.crop;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Emoji
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: AppTheme.radiusMedium,
              ),
              child: Center(
                  child:
                      Text(crop.emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),

            // Name + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crop.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(crop.farmerName,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textLight)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${crop.pricePerKg.toStringAsFixed(0)}/kg',
                    style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Qty stepper
            Column(
              children: [
                Row(
                  children: [
                    _QtyBtn(
                      icon: Icons.remove,
                      onTap: () {
                        final newQty =
                            item.quantityKg - (crop.minOrderKg ?? 10);
                        if (newQty < (crop.minOrderKg ?? 10)) {
                          notifier.removeItem(crop.id);
                        } else {
                          notifier.updateQuantity(crop.id, newQty);
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantityKg.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    _QtyBtn(
                      icon: Icons.add,
                      onTap: () => notifier.updateQuantity(
                          crop.id, item.quantityKg + (crop.minOrderKg ?? 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.subtotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppTheme.primaryGreen),
                ),
              ],
            ),

            // Remove
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.errorRed, size: 20),
              onPressed: () => notifier.removeItem(crop.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppTheme.primaryGreen),
        ),
      );
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  const _CheckoutBar({required this.total});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.totalAmount,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textLight)),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.buyerCheckout),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(l.proceedToCheckout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
