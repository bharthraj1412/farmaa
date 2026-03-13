import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/my-crops') || location.startsWith('/farmer/')) {
      return 1;
    }
    if (location.startsWith('/cart')) {
      return 2;
    }
    if (location.startsWith('/orders')) {
      return 3;
    }
    if (location.startsWith('/profile')) {
      return 4;
    }
    // Default to Home (Market feed)
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.myCrops);
        break;
      case 2:
        context.go(AppRoutes.cart);
        break;
      case 3:
        context.go(AppRoutes.orders);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currentIndex = _calculateSelectedIndex(context);

    // Using NavigationBar for Material 3 standard look
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: AppTheme.primaryGreen),
            label: 'Market', // Replaced l.browse with explicit label if missing
          ),
          NavigationDestination(
            icon: const Icon(Icons.grass_outlined),
            selectedIcon: const Icon(Icons.grass, color: AppTheme.primaryGreen),
            label: l.myCrops,
          ),
          const NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: AppTheme.primaryGreen),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppTheme.primaryGreen),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppTheme.primaryGreen),
            label: l.profile,
          ),
        ],
      ),
    );
  }
}
