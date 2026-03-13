import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/crop_service.dart';
import '../../../core/theme/app_theme.dart';

class CropDetailScreen extends ConsumerStatefulWidget {
  final String cropId;
  const CropDetailScreen({super.key, required this.cropId});

  @override
  ConsumerState<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends ConsumerState<CropDetailScreen> {
  CropModel? _crop;
  bool _isLoading = true;
  double _qty = 100;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final crop = await CropService.instance.getCropById(widget.cropId);
      if (mounted) {
        setState(() {
          _crop = crop;
          double minOrder = crop.minOrderKg ?? 10;
          _qty = minOrder;
          if (_qty > crop.stockKg) _qty = crop.stockKg;
          if (_qty < 0) _qty = 0;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addToCart() {
    if (_crop == null) return;
    ref.read(cartNotifierProvider.notifier).addItem(_crop!, _qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_qty.toStringAsFixed(0)} kg of ${_crop!.name} added to cart!'),
        backgroundColor: AppTheme.successGreen,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.go(AppRoutes.buyerCart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      bottomNavigationBar: _crop != null ? _bottomBar : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _crop == null
              ? const Center(child: Text('Crop not found'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final crop = _crop!;
    final totalAmount = crop.pricePerKg * _qty;

    return CustomScrollView(
      slivers: [
        // ── Image Header ──
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppTheme.cardGradient),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(crop.emoji, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: AppTheme.radiusRound,
                      ),
                      child: Text(
                        crop.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Content ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + verified
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(crop.name,
                              style: Theme.of(context).textTheme.headlineSmall),
                          if (crop.variety != null)
                            Text(crop.variety!,
                                style: const TextStyle(
                                    color: AppTheme.textMedium)),
                        ],
                      ),
                    ),
                    if (crop.isFarmerVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.infoBlue.withValues(alpha: 0.1),
                          borderRadius: AppTheme.radiusRound,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified,
                                size: 14, color: AppTheme.infoBlue),
                            SizedBox(width: 4),
                            Text('Verified',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.infoBlue,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price
                Row(
                  children: [
                    Text(
                      '₹${crop.pricePerKg.toStringAsFixed(0)}/kg',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                if (crop.lastPriceUpdate != null)
                  Text(
                    'Updated: ${_dateStr(crop.lastPriceUpdate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textLight),
                  ),
                const SizedBox(height: 4),

                // AI price insight
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.08),
                    borderRadius: AppTheme.radiusMedium,
                    border: Border.all(
                        color: AppTheme.accentAmber.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Text('✨', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Live market price — updated by verified seller',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.accentAmberDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Farmer info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.radiusLarge,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppTheme.primaryGreen.withValues(alpha: 0.1),
                        child: Text(
                          crop.farmerName.isNotEmpty ? crop.farmerName[0] : 'F',
                          style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(crop.farmerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text('${crop.farmerDistrict} District',
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textLight)),
                          ],
                        ),
                      ),
                      Text(
                        '${crop.stockKg.toStringAsFixed(0)} kg available',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (crop.description != null) ...[
                  Text('About', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(crop.description!,
                      style: const TextStyle(
                          color: AppTheme.textMedium, height: 1.5)),
                  const SizedBox(height: 16),
                ],

                // Quantity selector
                Text('Quantity',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_qty.toStringAsFixed(0)} kg'),
                        Text(
                          'Max: ${crop.stockKg.toStringAsFixed(0)} kg',
                          style: const TextStyle(
                              color: AppTheme.textLight, fontSize: 12),
                        ),
                      ],
                    ),
                    if (crop.stockKg >= (crop.minOrderKg ?? 10))
                      Slider(
                        value: _qty.clamp(crop.minOrderKg ?? 10, crop.stockKg),
                        min: crop.minOrderKg ?? 10,
                        max: crop.stockKg,
                        divisions: ((crop.stockKg - (crop.minOrderKg ?? 10)) / 10)
                            .round()
                            .clamp(1, 100),
                        activeColor: AppTheme.primaryGreen,
                        onChanged: (v) => setState(() => _qty = v),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Not enough stock to meet minimum order',
                          style: TextStyle(color: AppTheme.errorRed, fontSize: 13),
                        ),
                      ),
                  ],
                ),

                // Order summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: AppTheme.radiusLarge,
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Quantity', '${_qty.toStringAsFixed(0)} kg'),
                      _summaryRow(
                          'Price', '₹${crop.pricePerKg.toStringAsFixed(0)}/kg'),
                      const Divider(height: 16),
                      _summaryRow(
                        'Total',
                        '₹${totalAmount.toStringAsFixed(0)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                  color: isTotal ? AppTheme.textDark : AppTheme.textMedium,
                  fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                )),
            Text(value,
                style: TextStyle(
                  color: isTotal ? AppTheme.primaryGreen : AppTheme.textDark,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                  fontSize: isTotal ? 18 : 14,
                )),
          ],
        ),
      );

  Widget get _bottomBar => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go(
                    AppRoutes.buyerCheckout,
                    extra: {'crop': _crop!, 'quantity': _qty},
                  ),
                  icon: const Icon(Icons.bolt),
                  label: const Text('Buy Now'),
                ),
              ),
            ],
          ),
        ),
      );

  String _dateStr(DateTime? dt) {
    if (dt == null) return 'N/A';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}
