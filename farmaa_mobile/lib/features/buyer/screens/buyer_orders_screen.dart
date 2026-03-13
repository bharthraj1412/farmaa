import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/order_service.dart';
import '../../../generated/l10n/app_localizations.dart';

class BuyerOrdersScreen extends ConsumerStatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  ConsumerState<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends ConsumerState<BuyerOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final orders = await OrderService.instance.getMyOrders();
      if (mounted) setState(() => _orders = orders);
    } catch (_) {
      if (mounted) setState(() => _orders = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      color: AppTheme.surfaceCream,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🛒', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(l.noOrdersYet,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(l.ordersAppearHere,
                          style: const TextStyle(color: AppTheme.textLight)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (ctx, i) => _buildOrderCard(ctx, _orders[i]),
                  ),
                ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final statusColors = {
      OrderStatus.pending: AppTheme.warningAmber,
      OrderStatus.confirmed: AppTheme.infoBlue,
      OrderStatus.processing: AppTheme.infoBlue,
      OrderStatus.shipped: AppTheme.accentAmberDark,
      OrderStatus.delivered: AppTheme.successGreen,
      OrderStatus.cancelled: AppTheme.errorRed,
    };
    final color = statusColors[order.status] ?? AppTheme.textLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(order.cropCategory == 'Millet' ? '🌾' : '🌿',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.cropName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('from ${order.farmerName}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppTheme.radiusRound,
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _detail(
                    Icons.scale, '${order.quantityKg.toStringAsFixed(0)} kg'),
                const SizedBox(width: 16),
                _detail(
                    Icons.currency_rupee, order.totalAmount.toStringAsFixed(0)),
                const Spacer(),
                _detail(
                  order.paymentStatus == PaymentStatus.paid
                      ? Icons.check_circle
                      : Icons.pending_outlined,
                  order.paymentStatus.label,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 13, color: AppTheme.textMedium),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
        ],
      );
}
