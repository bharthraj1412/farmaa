import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

/// Crop/grain listing model. Prices are always editable by the seller.
@immutable
class CropModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerDistrict;
  final bool isFarmerVerified;

  final String name;
  final String category; // Any AppConstants.cropCategories value
  final String? variety;
  final String? description;
  final List<String> imageUrls;

  final double pricePerKg;
  final double stockKg;
  final double? minOrderKg;

  final DateTime? lastPriceUpdate; // Timestamp only — no lock logic
  final bool isApproved;
  final String status; // 'pending_qa' | 'approved' | 'rejected' | 'sold_out'

  final double? rating;
  final int reviewCount;

  final DateTime createdAt;
  final DateTime updatedAt;

  const CropModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerDistrict,
    required this.isFarmerVerified,
    required this.name,
    required this.category,
    required this.pricePerKg,
    required this.stockKg,
    required this.isApproved,
    required this.status,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
    this.variety,
    this.description,
    this.imageUrls = const [],
    this.minOrderKg,
    this.lastPriceUpdate,
    this.rating,
  });

  // ── Helpers ──────────────────────────────────────────────

  String get emoji => AppConstants.cropEmojis[category] ?? '🌾';
  bool get isAvailable => status == 'approved' && stockKg > 0;
  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  // ── Factory ──────────────────────────────────────────────

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id']?.toString() ?? '',
      farmerId: json['farmer_id']?.toString() ?? '',
      farmerName: json['farmer_name']?.toString() ?? 'Farmer',
      farmerDistrict: json['farmer_district']?.toString() ?? '',
      isFarmerVerified: json['farmer_verified'] as bool? ?? false,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      variety: json['variety']?.toString(),
      description: json['description']?.toString(),
      imageUrls: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble() ?? 0.0,
      stockKg: (json['stock_kg'] as num?)?.toDouble() ?? 0.0,
      minOrderKg: (json['min_order_kg'] as num?)?.toDouble(),
      lastPriceUpdate: json['last_price_update'] != null
          ? DateTime.tryParse(json['last_price_update'].toString())
          : null,
      isApproved: json['is_available'] as bool? ?? json['is_approved'] as bool? ?? false,
      status: json['status']?.toString() ?? 'pending_qa',
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as int?) ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        if (variety != null) 'variety': variety,
        if (description != null) 'description': description,
        'price_per_kg': pricePerKg,
        'stock_kg': stockKg,
        if (minOrderKg != null) 'min_order_kg': minOrderKg,
      };
}
