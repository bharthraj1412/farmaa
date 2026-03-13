import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Persistent bottom-nav shell for farmer feature area.
class FarmerShell extends StatelessWidget {
  final Widget child;
  const FarmerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final l = AppLocalizations.of(context);

    final navItems = [
      _NavItem(
          icon: Icons.home_rounded,
          label: l.dashboard,
          route: AppRoutes.farmerHome),
      _NavItem(
          icon: Icons.grass_rounded,
          label: l.myCrops,
          route: AppRoutes.farmerCrops),
      _NavItem(
          icon: Icons.bar_chart_rounded,
          label: l.marketPrices,
          route: AppRoutes.farmerPrices),
      _NavItem(
          icon: Icons.auto_awesome_rounded,
          label: l.aiAssistant,
          route: AppRoutes.farmerAI),
      _NavItem(
          icon: Icons.shopping_bag_outlined,
          label: l.orders,
          route: AppRoutes.farmerOrders),
      _NavItem(
          icon: Icons.person_rounded,
          label: l.profile,
          route: AppRoutes.farmerProfile),
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
                  .map((item) => _buildNavItem(context, item, location))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item, String location) {
    final isActive = location.startsWith(item.route) ||
        (item.route == AppRoutes.farmerHome &&
            location == AppRoutes.farmerHome);

    return GestureDetector(
      onTap: () => context.go(item.route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: AppTheme.radiusRound,
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isActive ? AppTheme.primaryGreen : AppTheme.textLight,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppTheme.primaryGreen : AppTheme.textLight,
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
