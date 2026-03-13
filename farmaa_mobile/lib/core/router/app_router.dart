import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/farmer/screens/farmer_shell.dart';
import '../../features/farmer/screens/farmer_dashboard.dart';
import '../../features/farmer/screens/crop_list_screen.dart';
import '../../features/farmer/screens/add_edit_crop_screen.dart';
import '../../features/farmer/screens/market_prices_screen.dart';
import '../../features/farmer/screens/farmer_ai_screen.dart';
import '../../features/farmer/screens/farmer_orders_screen.dart';
import '../../features/buyer/screens/buyer_shell.dart';
import '../../features/buyer/screens/buyer_dashboard.dart';
import '../../features/buyer/screens/cart_screen.dart';
import '../../features/buyer/screens/checkout_screen.dart';
import '../../features/buyer/screens/crop_detail_screen.dart';
import '../../features/buyer/screens/buyer_orders_screen.dart';
import '../../features/shared/screens/profile_screen.dart';
import '../../features/shared/screens/settings_screen.dart';
import '../../features/ai_chat/screens/ai_chat_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/buyer/screens/order_confirmation_screen.dart';
import '../../features/shared/screens/notifications_screen.dart';
import '../../core/models/crop_model.dart';

/// Application routes
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const farmerHome = '/farmer';
  static const farmerCrops = '/farmer/crops';
  static const farmerAddCrop = '/farmer/crops/add';
  static const farmerCropEdit = '/farmer/crops/:id/edit';
  static const farmerPrices = '/farmer/prices';
  static const farmerAI = '/farmer/ai';
  static const farmerOrders = '/farmer/orders';
  static const farmerProfile = '/farmer/profile';
  static const buyerHome = '/buyer';
  static const buyerCropDetail = '/buyer/crop/:id';
  static const buyerCart = '/buyer/cart';
  static const buyerCheckout = '/buyer/checkout';
  static const buyerOrders = '/buyer/orders';
  static const buyerProfile = '/buyer/profile';
  static const aiChat = '/ai-chat';
  static const settings = '/settings';
  static const admin = '/admin';
  static const notifications = '/notifications';
  static const orderConfirmation = '/buyer/order-confirmed';
}

/// A provider that creates and maintains a single GoRouter instance.
/// This prevents the "reload loop" caused by recreating the router on state changes.
final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _RouterListenable(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: listenable,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Oops! Page not found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(state.uri.path),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final splashFinished = ref.read(splashFinishedProvider);
      final location = state.matchedLocation;

      debugPrint(
          '[Router] Redirect check: location=$location, isLoading=${authState.isLoading}, splashFinished=$splashFinished');

      // Ensure splash animation finishes before we move away from root
      if (!splashFinished && location == AppRoutes.splash) return null;

      // Handle loading state - ONLY block if splash hasn't finished its window
      // but if splash is done, we MUST transition to give user feedback.
      if (authState.isLoading && !splashFinished) return null;

      final user = authState.user;

      // Unauthenticated logic
      if (user == null) {
        // If splash is done, we MUST leave the splash screen.
        // We go to Onboarding as the default unauthenticated entry point.
        if (splashFinished && location == AppRoutes.splash) {
          return AppRoutes.onboarding;
        }

        final publicRoutes = [
          AppRoutes.onboarding,
          AppRoutes.login,
        ];
        if (publicRoutes.contains(location)) return null;
        return AppRoutes.login;
      }

      // Authenticated logic — redirect away from auth screens
      if ([AppRoutes.splash, AppRoutes.onboarding, AppRoutes.login]
          .contains(location)) {
        return user.isFarmer ? AppRoutes.farmerHome : AppRoutes.buyerHome;
      }

      // Role-based guards
      if (location.startsWith('/farmer') && !user.isFarmer && !user.isAdmin) {
        return AppRoutes.buyerHome;
      }
      if (location.startsWith('/buyer') && user.isFarmer && !user.isAdmin) {
        return AppRoutes.farmerHome;
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),

      // ── Farmer Shell ──────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => FarmerShell(child: child),
        routes: [
          GoRoute(
              path: AppRoutes.farmerHome,
              builder: (_, __) => const FarmerDashboard()),
          GoRoute(
              path: AppRoutes.farmerCrops,
              builder: (_, __) => const CropListScreen()),
          GoRoute(
            path: AppRoutes.farmerAddCrop,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AddEditCropScreen(),
              transitionsBuilder: (_, animation, __, child) => SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 1), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.farmerCropEdit,
            builder: (context, state) => AddEditCropScreen(
              cropId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
              path: AppRoutes.farmerPrices,
              builder: (_, __) => const MarketPricesScreen()),
          GoRoute(
              path: AppRoutes.farmerAI,
              builder: (_, __) => const FarmerAIScreen()),
          GoRoute(
              path: AppRoutes.farmerOrders,
              builder: (_, __) => const FarmerOrdersScreen()),
          GoRoute(
              path: AppRoutes.farmerProfile,
              builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Buyer Shell ───────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => BuyerShell(child: child),
        routes: [
          GoRoute(
              path: AppRoutes.buyerHome,
              builder: (_, __) => const BuyerDashboard()),
          GoRoute(
            path: AppRoutes.buyerCropDetail,
            builder: (context, state) => CropDetailScreen(
              cropId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
              path: AppRoutes.buyerCart,
              builder: (_, __) => const CartScreen()),
          GoRoute(
            path: AppRoutes.buyerCheckout,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              if (extra == null) return const CartScreen();
              return CheckoutScreen(
                crop: extra['crop'] as CropModel,
                quantity: extra['quantity'] as double,
              );
            },
          ),
          GoRoute(
              path: AppRoutes.buyerOrders,
              builder: (_, __) => const BuyerOrdersScreen()),
          GoRoute(
              path: AppRoutes.buyerProfile,
              builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        builder: (_, __) => const AIChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (_, __) => const AdminDashboard(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderConfirmation,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OrderConfirmationScreen(
            orderId: extra['orderId']?.toString() ?? 'ORD-DEMO',
            cropName: extra['cropName']?.toString() ?? '',
            quantity: (extra['quantity'] as num?)?.toDouble() ?? 0,
            totalAmount: (extra['totalAmount'] as num?)?.toDouble() ?? 0,
          );
        },
      ),
    ],
  );
});

/// A Listenable that triggers GoRouter refreshes when auth state changes or splash finishes.
class _RouterListenable extends ChangeNotifier {
  _RouterListenable(Ref ref) {
    _subscription = ref.listen(
      authProvider,
      (_, __) => notifyListeners(),
    );
    _splashSubscription = ref.listen(
      splashFinishedProvider,
      (_, __) => notifyListeners(),
    );
  }
  late final ProviderSubscription _subscription;
  late final ProviderSubscription _splashSubscription;

  @override
  void dispose() {
    _subscription.close();
    _splashSubscription.close();
    super.dispose();
  }
}
