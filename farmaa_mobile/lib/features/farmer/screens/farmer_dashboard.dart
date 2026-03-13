import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/crop_service.dart';
import '../../../core/models/crop_model.dart';
import '../../shared/widgets/stat_card.dart';
import '../../../main.dart'; // For initializeAppServices
import '../../../generated/l10n/app_localizations.dart';

class FarmerDashboard extends ConsumerStatefulWidget {
  const FarmerDashboard({super.key});

  @override
  ConsumerState<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends ConsumerState<FarmerDashboard> {
  List<CropModel> _myListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Lazy-load heavy services once after dashboard initializes
    WidgetsBinding.instance
        .addPostFrameCallback((_) => initializeAppServices());
  }

  Future<void> _loadData() async {
    try {
      final listings = await CropService.instance.getMyListings();
      if (mounted) {
        setState(() {
          _myListings = listings;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.name.split(' ').first ?? 'Farmer';
    final l = AppLocalizations.of(context);

    const pendingOrders = 0; // would come from orders provider
    final activeCrops = _myListings.where((c) => c.isAvailable).length;
    final soldOutCrops =
        _myListings.where((c) => c.status == 'sold_out').length;

    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryGreen,
        child: CustomScrollView(
          slivers: [
            // ── Hero Header ──
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppTheme.primaryGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: RepaintBoundary(
                  child: Container(
                    decoration:
                        const BoxDecoration(gradient: AppTheme.heroGradient),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello, $firstName 👋',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      l.dashboard,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Notifications bell
                                    GestureDetector(
                                      onTap: () =>
                                          context.push(AppRoutes.notifications),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Profile avatar
                                    GestureDetector(
                                      onTap: () =>
                                          context.go(AppRoutes.farmerProfile),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.2),
                                        child: Text(
                                          firstName[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (!(user?.isVerified ?? false))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentAmber
                                      .withValues(alpha: 0.2),
                                  borderRadius: AppTheme.radiusMedium,
                                  border: Border.all(
                                      color: AppTheme.accentAmber, width: 0.5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        color: AppTheme.accentAmber, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      l.verificationPending,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Stats Row ──
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.grass,
                          label: l.myCrops,
                          value: '$activeCrops',
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.shopping_bag,
                          label: l.orders,
                          value: '$pendingOrders',
                          color: AppTheme.accentAmber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.sell_outlined,
                          label: l.cancelled,
                          value: '$soldOutCrops',
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Quick Actions ──
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.dashboard,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _quickActionBtn(
                            context,
                            icon: Icons.add_circle_outline,
                            label: l.addGrain,
                            onTap: (user?.isVerified ?? false)
                                ? () => context.go(AppRoutes.farmerAddCrop)
                                : null,
                            disabled: !(user?.isVerified ?? false),
                          ),
                          const SizedBox(width: 12),
                          _quickActionBtn(
                            context,
                            icon: Icons.trending_up_rounded,
                            label: l.marketPrices,
                            onTap: () => context.go(AppRoutes.farmerPrices),
                          ),
                          const SizedBox(width: 12),
                          _quickActionBtn(
                            context,
                            icon: Icons.auto_awesome,
                            label: l.aiAssistant,
                            onTap: () => context.go(AppRoutes.farmerAI),
                            highlight: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── My Listings ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.myCrops,
                        style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.farmerCrops),
                      child: const Text('See all →'),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_myListings.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          l.noGrainsFound,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: (user?.isVerified ?? false)
                              ? () => context.go(AppRoutes.farmerAddCrop)
                              : null,
                          child: Text(l.listNewGrain),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _DashboardCropRow(crop: _myListings[i]),
                  ),
                  childCount: _myListings.take(3).length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.aiChat),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _quickActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool disabled = false,
    bool highlight = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: highlight ? AppTheme.amberGradient : null,
              color: highlight ? null : Colors.white,
              borderRadius: AppTheme.radiusLarge,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: highlight ? Colors.white : AppTheme.primaryGreen,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: highlight ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCropRow extends StatelessWidget {
  final CropModel crop;
  const _DashboardCropRow({required this.crop});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: AppTheme.radiusMedium,
            ),
            child: Center(
              child: Text(crop.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop.name, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '₹${crop.pricePerKg.toStringAsFixed(0)}/${l.pricePerKg} · ${l.stockKg(crop.stockKg.toStringAsFixed(0))}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _StatusChip(crop: crop),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final CropModel crop;
  const _StatusChip({required this.crop});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Color color;
    String label;
    switch (crop.status) {
      case 'approved':
        color = AppTheme.successGreen;
        label = 'Live';
        break;
      case 'sold_out':
        color = AppTheme.errorRed;
        label = l.cancelled;
        break;
      case 'pending_qa':
        color = AppTheme.warningAmber;
        label = l.pending;
        break;
      default:
        color = AppTheme.textLight;
        label = crop.status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTheme.radiusRound,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
