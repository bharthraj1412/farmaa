/// Global application constants for Farmaa.
library;

import '../config/environment_config.dart';

class AppConstants {
  AppConstants._();

  // ── API ──────────────────────────────────────────────────
  /// Check if running in production mode
  static bool get isProduction => EnvironmentConfig.isProduction;

  /// Public HTTPS endpoint for production.
  static const String prodUrl = 'https://farmaa-ivory.vercel.app';

  /// Development URL (Android emulator maps 10.0.2.2 to host's localhost).
  static const String devUrl = 'http://10.0.2.2:10000';

  /// Base URL used throughout the app.
  /// Can be overridden at runtime for development/testing
  static String baseUrl = EnvironmentConfig.baseUrl;

  static const String baseUrlKey = 'farmaa_base_url';

  static const Duration connectTimeout =
      Duration(seconds: 15); // Increased for cloud
  static const Duration receiveTimeout =
      Duration(seconds: 20); // Increased for cloud

  // ── Auth ─────────────────────────────────────────────────
  static const String jwtKey = 'farmaa_jwt';
  static const String userKey = 'farmaa_user';
  static const String refreshTokenKey = 'farmaa_refresh';

  // ── Business Rules ────────────────────────────────────────
  // Prices are always editable — no time-based lock.

  // ── Grain Categories (parent + subcategories) ──────────────
  /// All supported grain subcategories.
  static const List<String> cropCategories = [
    'Rice',
    'Wheat',
    'Millet',
    'Barley',
    'Sorghum',
    'Maize',
    'Pulses',
    'Other',
  ];

  static const Map<String, String> cropEmojis = {
    'Rice': '🌾',
    'Wheat': '🌿',
    'Millet': '🌻',
    'Barley': '🌰',
    'Sorghum': '🌱',
    'Maize': '🌽',
    'Pulses': '🫘',
    'Other': '🌾',
    // Legacy mapping for backward compatibility with existing DB rows
    'millet': '🌾',
    'wheat': '🌿',
  };

  // ── Roles ─────────────────────────────────────────────────
  static const String roleFarmer = 'farmer';
  static const String roleBuyer = 'buyer';
  static const String roleAdmin = 'admin';

  // ── Pagination ────────────────────────────────────────────
  static const int pageSize = 20;

  // ── Razorpay ──────────────────────────────────────────────
  /// Replace with your actual Razorpay test key.
  static String get razorpayKey => EnvironmentConfig.razorpayKey;
  static String get razorpaySecret => EnvironmentConfig.razorpaySecret;

  // ── App Info ─────────────────────────────────────────────
  static const String appName = 'Farmaa';
  static const String appTagline = 'From Farm to Future';
}
