import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/crop_model.dart';

/// Manages crop listing, browsing, and inventory operations.
class CropService {
  CropService._();
  static final CropService instance = CropService._();

  final _dio = ApiClient().dio;

  // ── Browse (Buyer) ────────────────────────────────────────

  /// Fetches approved crop listings for buyers.
  Future<List<CropModel>> getCrops({
    String? category,
    String? district,
    String? search,
    String sortBy = 'created_at',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get('/crops/', queryParameters: {
      if (category != null) 'category': category,
      if (district != null) 'district': district,
      if (search != null) 'search': search,
      'skip': (page - 1) * limit,
      'limit': limit,
    });
    final items = (response.data as List<dynamic>?) ?? [];
    return items
        .map((e) => CropModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single crop by ID.
  Future<CropModel> getCropById(String cropId) async {
    final response = await _dio.get('/crops/$cropId');
    return CropModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Farmer's Own Listings ─────────────────────────────────

  /// Fetches current farmer's own crop listings.
  Future<List<CropModel>> getMyListings() async {
    final response = await _dio.get('/crops/my-listings');
    final items = (response.data as List<dynamic>?) ?? [];
    return items
        .map((e) => CropModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Create / Update ───────────────────────────────────────

  /// Creates a new crop listing.
  Future<CropModel> createCrop({
    required String name,
    required String category,
    String? variety,
    String? description,
    required double pricePerKg,
    required double stockKg,
    double? minOrderKg,
  }) async {
    try {
      final response = await _dio.post('/crops/', data: {
        'name': name,
        'category': category,
        if (variety != null) 'variety': variety,
        if (description != null) 'description': description,
        'price_per_kg': pricePerKg,
        'stock_kg': stockKg,
        if (minOrderKg != null) 'min_order_kg': minOrderKg,
      });
      return CropModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint(
          '[CropService] Create crop failed: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  /// Updates a crop listing. Price is always editable.
  Future<CropModel> updateCrop({
    required String cropId,
    double? pricePerKg,
    double? stockKg,
    String? description,
    double? minOrderKg,
  }) async {
    final response = await _dio.put('/crops/$cropId', data: {
      if (pricePerKg != null) 'price_per_kg': pricePerKg,
      if (stockKg != null) 'stock_kg': stockKg,
      if (description != null) 'description': description,
      if (minOrderKg != null) 'min_order_kg': minOrderKg,
    });
    return CropModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Permanently deletes a crop listing.
  Future<void> deleteCrop(String cropId) async {
    await _dio.delete('/crops/$cropId');
  }

  // ── Market Prices ─────────────────────────────────────────

  /// Fetches live market prices for a crop category and district.
  /// Falls back to empty list if backend endpoint is unavailable.
  Future<List<Map<String, dynamic>>> getMarketPrices({
    String? commodity,
    String? district,
  }) async {
    try {
      final response = await _dio.get('/market/prices', queryParameters: {
        if (commodity != null) 'commodity': commodity,
        if (district != null) 'district': district,
      });
      final items = (response.data as List<dynamic>?) ?? [];
      return items.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('[CropService] Market prices endpoint unavailable: $e');
      // Return empty list — market_prices_screen.dart has its own demo fallback
      return [];
    }
  }
}
