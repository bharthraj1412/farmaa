import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/crop_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

class CropListScreen extends ConsumerStatefulWidget {
  const CropListScreen({super.key});

  @override
  ConsumerState<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends ConsumerState<CropListScreen> {
  List<CropModel> _crops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final crops = await CropService.instance.getMyListings();
      if (mounted) {
        setState(() {
          _crops = crops;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      appBar: AppBar(
        title: Text(l.myCrops),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.farmerAddCrop),
        icon: const Icon(Icons.add),
        label: Text(l.listNewGrain),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _crops.isEmpty
              ? _buildEmpty(l)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _crops.length,
                    itemBuilder: (context, i) => _CropCard(
                      crop: _crops[i],
                      onEdit: () =>
                          context.go('/farmer/crops/${_crops[i].id}/edit'),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmpty(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(l.noGrainsFound, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l.tryDifferentSearch,
              style: const TextStyle(color: AppTheme.textLight)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.farmerAddCrop),
            icon: const Icon(Icons.add),
            label: Text(l.listNewGrain),
          ),
        ],
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final CropModel crop;
  final VoidCallback onEdit;

  const _CropCard({required this.crop, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(crop.status);
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
          // Top row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  child: Center(
                    child:
                        Text(crop.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              crop.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          // Status chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: AppTheme.radiusRound,
                            ),
                            child: Text(
                              crop.status.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (crop.variety != null)
                        Text(crop.variety!,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textLight)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '₹${crop.pricePerKg.toStringAsFixed(0)}/kg',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l.stockKg(crop.stockKg.toStringAsFixed(0)),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom action bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7F5),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (crop.lastPriceUpdate != null)
                  Text(
                    l.priceGuarantee(_dateStr(crop.lastPriceUpdate)),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textLight),
                  )
                else
                  const SizedBox.shrink(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(l.editListing),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      case 'pending_qa':
        return AppTheme.warningAmber;
      case 'sold_out':
        return AppTheme.textLight;
      default:
        return AppTheme.textLight;
    }
  }

  String _dateStr(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
