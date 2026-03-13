import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/crop_model.dart';

/// In-memory cart state managed by Riverpod.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  /// Add a crop to cart or increment quantity if it already exists.
  void addItem(CropModel crop, double quantityKg) {
    final idx = state.indexWhere((i) => i.crop.id == crop.id);
    if (idx >= 0) {
      // Upsert: add to existing qty, capped at stock
      final updated = state[idx].copyWith(
        quantityKg: (state[idx].quantityKg + quantityKg).clamp(
          crop.minOrderKg ?? 1,
          crop.stockKg,
        ),
      );
      state = [
        ...state.sublist(0, idx),
        updated,
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state, CartItem(crop: crop, quantityKg: quantityKg)];
    }
  }

  void removeItem(String cropId) {
    state = state.where((i) => i.crop.id != cropId).toList();
  }

  void updateQuantity(String cropId, double qty) {
    state = state.map((i) {
      if (i.crop.id == cropId) {
        return i.copyWith(
            quantityKg: qty.clamp(i.crop.minOrderKg ?? 1, i.crop.stockKg));
      }
      return i;
    }).toList();
  }

  void clear() => state = [];
}

final cartNotifierProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

/// Total cart value.
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartNotifierProvider).fold(0, (sum, i) => sum + i.subtotal);
});

/// Number of items in cart.
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartNotifierProvider).length;
});
