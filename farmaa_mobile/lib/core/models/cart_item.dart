import 'package:flutter/foundation.dart';
import 'crop_model.dart';

/// A single item in the buyer's cart.
@immutable
class CartItem {
  final CropModel crop;
  final double quantityKg;

  const CartItem({required this.crop, required this.quantityKg});

  double get subtotal => crop.pricePerKg * quantityKg;

  CartItem copyWith({CropModel? crop, double? quantityKg}) => CartItem(
        crop: crop ?? this.crop,
        quantityKg: quantityKg ?? this.quantityKg,
      );
}
