import 'package:flutter/material.dart';
import '../../farmer/screens/farmer_orders_screen.dart';
import '../../buyer/screens/buyer_orders_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceCream,
        appBar: AppBar(
          title: Text(l.myOrders),
          bottom: const TabBar(
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.textMedium,
            indicatorColor: AppTheme.primaryGreen,
            tabs: [
              Tab(icon: Icon(Icons.shopping_bag_outlined), text: "Purchases"),
              Tab(icon: Icon(Icons.sell_outlined), text: "Sales"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // We use the bodies of the original screens inside our unified scaffold
            _PurchasesTabWrapper(),
            _SalesTabWrapper(),
          ],
        ),
      ),
    );
  }
}

// Wrapping them like this allows us to reuse existing screens.
// We'll modify the original ones slightly to remove their Scaffolds/AppBars so they fit nicely here.
class _PurchasesTabWrapper extends StatelessWidget {
  const _PurchasesTabWrapper();
  @override
  Widget build(BuildContext context) {
    return const BuyerOrdersScreen();
  }
}

class _SalesTabWrapper extends StatelessWidget {
  const _SalesTabWrapper();
  @override
  Widget build(BuildContext context) {
    return const FarmerOrdersScreen();
  }
}
