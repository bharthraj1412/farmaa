import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/order_service.dart';
import '../../../generated/l10n/app_localizations.dart';

class FarmerOrdersScreen extends ConsumerStatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  ConsumerState<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends ConsumerState<FarmerOrdersScreen> {
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
      final orders = await OrderService.instance.getReceivedOrders();
      if (mounted) setState(() => _orders = orders);
    } catch (_) {
      // demo data fallback
      if (mounted) setState(() => _orders = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    try {
      await OrderService.instance.updateOrderStatus(orderId, status);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $status successfully'),
            backgroundColor: (status == 'confirmed' || status == 'delivered')
                ? AppTheme.successGreen
                : AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      appBar: AppBar(title: Text(l.receivedOrders)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📦', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(l.noOrdersYet,
                          style: Theme.of(context).textTheme.titleMedium),
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
                    itemBuilder: (ctx, i) => _OrderCard(
                      order: _orders[i],
                      onAccept: () => _updateStatus(_orders[i].id, 'confirmed'),
                      onReject: () => _updateStatus(_orders[i].id, 'cancelled'),
                    ),
                  ),
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _OrderCard({
    required this.order,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = order.status == OrderStatus.pending;
    final l = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  child: Text(
                    order.buyerName.isNotEmpty ? order.buyerName[0] : 'B',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.buyerName,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        '${order.cropName} · ${order.quantityKg.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                            color: AppTheme.textMedium, fontSize: 13),
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(0)} ${l.totalAmount.toLowerCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(order.status),
              ],
            ),
          ),
          if (isPending)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed),
                      ),
                      child: Text(l.cancelOrder),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      child: Text(l.confirmOrder),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusChip(OrderStatus status) {
    final colors = {
      OrderStatus.pending: AppTheme.warningAmber,
      OrderStatus.confirmed: AppTheme.successGreen,
      OrderStatus.cancelled: AppTheme.errorRed,
      OrderStatus.delivered: AppTheme.infoBlue,
    };
    final color = colors[status] ?? AppTheme.textLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTheme.radiusRound,
      ),
      child: Text(
        status.label,
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
