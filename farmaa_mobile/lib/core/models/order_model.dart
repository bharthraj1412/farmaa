import 'package:flutter/foundation.dart';

enum OrderStatus { pending, confirmed, processing, shipped, delivered, cancelled }
enum PaymentStatus { pending, paid, failed, refunded }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:    return 'Pending';
      case OrderStatus.confirmed:  return 'Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped:    return 'Shipped';
      case OrderStatus.delivered:  return 'Delivered';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }

  static OrderStatus fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'confirmed':  return OrderStatus.confirmed;
      case 'processing': return OrderStatus.processing;
      case 'shipped':    return OrderStatus.shipped;
      case 'delivered':  return OrderStatus.delivered;
      case 'cancelled':  return OrderStatus.cancelled;
      default:           return OrderStatus.pending;
    }
  }
}

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:  return 'Pending';
      case PaymentStatus.paid:     return 'Paid';
      case PaymentStatus.failed:   return 'Failed';
      case PaymentStatus.refunded: return 'Refunded';
    }
  }

  static PaymentStatus fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'paid':     return PaymentStatus.paid;
      case 'failed':   return PaymentStatus.failed;
      case 'refunded': return PaymentStatus.refunded;
      default:         return PaymentStatus.pending;
    }
  }
}

/// Order model representing a buyer-farmer transaction.
@immutable
class OrderModel {
  final String id;
  final String cropId;
  final String cropName;
  final String cropCategory;
  final String cropImageUrl;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;

  final double quantityKg;
  final double pricePerKg;
  final double totalAmount;
  final double? taxAmount;

  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentId; // Razorpay payment ID
  final String? razorpayOrderId;

  final String deliveryAddress;
  final DateTime? estimatedDelivery;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.cropId,
    required this.cropName,
    required this.cropCategory,
    required this.cropImageUrl,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.quantityKg,
    required this.pricePerKg,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.deliveryAddress,
    required this.createdAt,
    required this.updatedAt,
    this.taxAmount,
    this.paymentId,
    this.razorpayOrderId,
    this.estimatedDelivery,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      cropId: json['crop_id']?.toString() ?? '',
      cropName: json['crop_name']?.toString() ?? '',
      cropCategory: json['crop_category']?.toString() ?? 'Wheat',
      cropImageUrl: json['crop_image']?.toString() ?? '',
      farmerId: json['farmer_id']?.toString() ?? '',
      farmerName: json['farmer_name']?.toString() ?? 'Farmer',
      farmerPhone: json['farmer_phone']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString() ?? '',
      buyerName: json['buyer_name']?.toString() ?? 'Buyer',
      buyerPhone: json['buyer_phone']?.toString() ?? '',
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble(),
      status: OrderStatusX.fromString(json['status']?.toString()),
      paymentStatus: PaymentStatusX.fromString(json['payment_status']?.toString()),
      paymentId: json['payment_id']?.toString(),
      razorpayOrderId: json['razorpay_order_id']?.toString(),
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.tryParse(json['estimated_delivery'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
