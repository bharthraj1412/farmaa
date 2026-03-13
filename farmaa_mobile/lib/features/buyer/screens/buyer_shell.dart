import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

class BuyerShell extends ConsumerWidget {
  final Widget child;
  const BuyerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final cartCount = ref.watch(cartCountProvider);
    final l = AppLocalizations.of(context);

    final navItems = [
      _NavItem(
          icon: Icons.storefront_rounded,
          label: l.browse,
          route: AppRoutes.buyerHome),
      _NavItem(
          icon: Icons.shopping_cart_rounded,
          label: l.cart,
          route: AppRoutes.buyerCart),
      _NavItem(
          icon: Icons.receipt_long_rounded,
          label: l.orders,
          route: AppRoutes.buyerOrders),
      _NavItem(
          icon: Icons.person_rounded,
          label: l.profile,
          route: AppRoutes.buyerProfile),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems
                  .map((item) =>
                      _buildNavItem(context, item, location, cartCount))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, _NavItem item, String location, int cartCount) {
    final isActive = location.startsWith(item.route);
    final showBadge = item.route == AppRoutes.buyerCart && cartCount > 0;

    return GestureDetector(
      onTap: () => context.go(item.route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppTheme.accentAmber.withValues(alpha: 0.1),
                borderRadius: AppTheme.radiusRound,
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(item.icon,
                    size: 22,
                    color: isActive
                        ? AppTheme.accentAmberDark
                        : AppTheme.textLight),
                if (showBadge)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          cartCount > 9 ? '9+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppTheme.accentAmberDark : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(
      {required this.icon, required this.label, required this.route});
}
