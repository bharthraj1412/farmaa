import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../main.dart'; // For initializeAppServices
import '../../../core/router/app_router.dart';
import '../../../core/services/crop_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

class BuyerDashboard extends ConsumerStatefulWidget {
  const BuyerDashboard({super.key});

  @override
  ConsumerState<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends ConsumerState<BuyerDashboard> {
  List<CropModel> _crops = [];
  bool _isLoading = true;
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
    // Lazy-load heavy services once after dashboard initializes
    WidgetsBinding.instance
        .addPostFrameCallback((_) => initializeAppServices());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final crops = await CropService.instance.getCrops(
        category: _selectedCategory,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      if (mounted) setState(() => _crops = crops);
    } catch (_) {
      if (mounted) setState(() => _crops = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.name.split(' ').first ?? 'Buyer';
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      body: CustomScrollView(
        slivers: [
          // ── Amber Header ──
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.accentAmberDark,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                tooltip: l.notifications,
                onPressed: () => context.push(AppRoutes.notifications),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: RepaintBoundary(
                child: Container(
                  decoration:
                      const BoxDecoration(gradient: AppTheme.amberGradient),
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $firstName 👋',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l.tagline,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      // Search bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.radiusRound,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search,
                                color: AppTheme.textLight, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onSubmitted: (v) {
                                  setState(() => _searchQuery = v);
                                  _load();
                                },
                                decoration: InputDecoration(
                                  hintText: l.searchCrops,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
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

          // ── Category Filter ──
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [null, ...AppConstants.cropCategories].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      final emoji = cat == null
                          ? '🌾'
                          : (AppConstants.cropEmojis[cat] ?? '🌾');
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          _load();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentAmberDark
                                : Colors.white,
                            borderRadius: AppTheme.radiusRound,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accentAmberDark
                                  : AppTheme.borderLight,
                            ),
                          ),
                          child: Text(
                            cat == null ? '🌾 ${l.allGrains}' : '$emoji $cat',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color:
                                  isSelected ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // ── Results Count ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                _isLoading ? l.loading : l.listingsFound(_crops.length),
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
            ),
          ),

          // ── Crop Grid ──
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
              : _crops.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(l.noGrainsFound,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(l.tryDifferentSearch,
                                style:
                                    const TextStyle(color: AppTheme.textLight)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _CropGridCard(
                            crop: _crops[i],
                            onTap: () =>
                                context.go('/buyer/crop/${_crops[i].id}'),
                          ),
                          childCount: _crops.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.aiChat),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}

class _CropGridCard extends StatelessWidget {
  final CropModel crop;
  final VoidCallback onTap;

  const _CropGridCard({required this.crop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / emoji area
            Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Text(crop.emoji, style: const TextStyle(fontSize: 44)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  if (crop.variety != null)
                    Text(
                      crop.variety!,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight),
                    ),
                  Text(
                    crop.farmerDistrict,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${crop.pricePerKg.toStringAsFixed(0)}/kg',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Market price indicator for buyers
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.08),
                      borderRadius: AppTheme.radiusRound,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 9, color: AppTheme.successGreen),
                        const SizedBox(width: 3),
                        Text(
                          l.marketPrice,
                          style: const TextStyle(
                              fontSize: 9,
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (crop.isFarmerVerified) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.verified,
                            size: 11, color: AppTheme.infoBlue),
                        const SizedBox(width: 3),
                        Text(l.verifiedAccount,
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.infoBlue)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
