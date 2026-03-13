import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager for Farmaa mobile app
/// Uses flutter_dotenv to load configuration from .env file
class EnvironmentConfig {
  EnvironmentConfig._();

  static bool _isInitialized = false;

  /// Initialize environment configuration
  /// Call this in main.dart before runApp()
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: ".env");
      _isInitialized = true;
      debugPrint('[EnvironmentConfig] Environment loaded successfully');
    } catch (e) {
      debugPrint('[EnvironmentConfig] Failed to load .env file: $e');
      debugPrint('[EnvironmentConfig] Using default/fallback configuration');
      _isInitialized = true;
    }
  }

  /// Get environment variable
  static String? get(String key) {
    return dotenv.env[key];
  }

  /// Current environment (development | production)
  static String get environment => get('ENVIRONMENT') ?? 'development';

  /// Check if running in production mode
  static bool get isProduction => environment == 'production';

  /// Supabase configuration
  static String get supabaseUrl {
    return get('SUPABASE_URL') ?? 'https://qhllzkyklmvvvqkpzhbj.supabase.co';
  }

  static String get supabaseAnonKey {
    return get('SUPABASE_ANON_KEY') ??
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFobGx6a3lrbG12dnZxa3B6aGJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4OTQ5MjgsImV4cCI6MjA4ODQ3MDkyOH0.xi1saJm4uW9o4luK0_dvWdi2lM1xA50dStIqUGEE4wM';
  }

  /// API configuration
  static String get baseUrl {
    // Allow override via environment variable
    final override = get('BASE_URL');
    if (override != null && override.isNotEmpty) {
      return override;
    }

    // Default based on environment
    if (isProduction) {
      return 'https://farmaa-ivory.vercel.app';
    } else {
      return 'http://10.0.2.2:10000'; // Android emulator
    }
  }

  /// Razorpay configuration
  static String get razorpayKey {
    return get('RAZORPAY_KEY') ?? 'rzp_test_SKmYp2ETrwBn0s';
  }

  static String get razorpaySecret {
    return get('RAZORPAY_SECRET') ?? 'VQIMyqA3HzFF04ljBmu4GBYO';
  }

  /// Debug information
  static void printDebugInfo() {
    if (!kReleaseMode) {
      debugPrint('=== Environment Configuration ===');
      debugPrint('Environment: $environment');
      debugPrint('Is Production: $isProduction');
      debugPrint('Base URL: $baseUrl');
      debugPrint('Supabase URL: $supabaseUrl');
      debugPrint('================================');
    }
  }
}
