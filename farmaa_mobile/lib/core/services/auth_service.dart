import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'google_auth_service.dart';

/// Handles all authentication operations: OTP send/verify, token storage.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _dio = ApiClient().dio;
  static const _storage = FlutterSecureStorage();
  static SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Flag to track if the backend is unreachable.
  /// If true, we skip real network calls to avoid repeated 3s timeouts.
  bool _backendIsDown = false;

  // ── OTP Flow ─────────────────────────────────────────────

  /// Sends OTP to the given phone number.
  Future<void> sendOtp(String phone) async {
    ApiClient().resetCircuitBreaker(); // Force retry if they fixed the IP
    if (_backendIsDown) {
      debugPrint(
          '[AuthService] Skipping network call — backend marked as DOWN');
      return;
    }
    try {
      await _dio.post('/auth/send-otp', data: {'phone': phone});
    } on DioException {
      _backendIsDown = true;
      debugPrint(
          '[AuthService] Backend unreachable — demo OTP mode active (use 123456)');
    }
  }

  /// Verifies OTP and creates/fetches the user account.
  /// Returns the authenticated [UserModel].
  Future<({UserModel user, String token})> verifyOtp({
    required String phone,
    required String otp,
    required String role,
    required String name,
    String? village,
    String? district,
    String? organization,
  }) async {
    // ── Demo / offline mode ─────────────────────────────────────
    // Accept '123456' as a universal test OTP when backend is unavailable.
    if (otp == '123456') {
      if (_backendIsDown) {
        return _createDemoSession(
            phone, name, role, village, district, organization);
      }
      try {
        final response = await _dio.post('/auth/verify-otp', data: {
          'phone': phone,
          'otp': otp,
          'role': role,
          'name': name,
          if (village != null) 'village': village,
          if (district != null) 'district': district,
          if (organization != null) 'org': organization,
        });
        final data = response.data as Map<String, dynamic>;
        final token = data['access_token']?.toString() ?? 'demo_token';
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        await _persistSession(token: token, user: user);
        return (user: user, token: token);
      } on DioException {
        _backendIsDown = true;
        return _createDemoSession(
            phone, name, role, village, district, organization);
      }
    }

    // ── Normal backend flow ─────────────────────────────────────
    final response = await _dio.post('/auth/verify-otp', data: {
      'phone': phone,
      'otp': otp,
      'role': role,
      'name': name,
      if (village != null) 'village': village,
      if (district != null) 'district': district,
      if (organization != null) 'org': organization,
    });

    final data = response.data as Map<String, dynamic>;
    final token = data['access_token']?.toString() ?? '';
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await _persistSession(token: token, user: user);
    return (user: user, token: token);
  }

  // ── Session Management ────────────────────────────────────

  Future<void> _persistSession({
    required String token,
    required UserModel user,
  }) async {
    await _initPrefs();
    await Future.wait([
      _storage.write(key: AppConstants.jwtKey, value: token),
      _prefs!.setString(AppConstants.userKey, jsonEncode(user.toJson())),
    ]);
  }

  /// Loads the persisted user from storage, if any.
  Future<UserModel?> getPersistedUser() async {
    await _initPrefs();
    final raw = _prefs!.getString(AppConstants.userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if a valid JWT token exists in storage.
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.jwtKey);
    return token != null && token.isNotEmpty;
  }

  /// Clears all session data and logs the user out.
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException {
      // Ignore network errors on logout
    } finally {
      await GoogleAuthService.instance.signOut();
      await _storage.deleteAll();
      await _initPrefs();
      await _prefs!.clear();
    }
  }

  // ── Profile ───────────────────────────────────────────────

  /// Fetches the current user's full profile from the server.
  Future<UserModel> getProfile() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates editable profile fields.
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
    String? village,
    String? district,
    String? organization,
  }) async {
    final response = await _dio.patch('/auth/me', data: {
      'name': name,
      if (phone != null) 'phone': phone,
      if (village != null) 'village': village,
      if (district != null) 'district': district,
      if (organization != null) 'org': organization,
    });
    final user = UserModel.fromJson(response.data as Map<String, dynamic>);
    await _initPrefs();
    await _prefs!.setString(
      AppConstants.userKey,
      jsonEncode(user.toJson()),
    );
    return user;
  }

  Future<({UserModel user, String token})> _createDemoSession(
      String phone,
      String name,
      String role,
      String? village,
      String? district,
      String? organization) async {
    final demoUser = UserModel(
      id: 'demo_${phone.replaceAll('+', '')}',
      name: name.isNotEmpty ? name : 'Demo User',
      phone: phone.isNotEmpty ? phone : null,
      role: role,
      village: village,
      district: district,
      organization: organization,
      isVerified: true,
      createdAt: DateTime.now(),
    );
    await _persistSession(token: 'demo_token', user: demoUser);
    return (user: demoUser, token: 'demo_token');
  }

  /// Login with Google Sign-In.
  Future<({UserModel user, String token})> loginWithGoogle({
    required String role,
    String? village,
    String? district,
    String? organization,
  }) async {
    final result = await GoogleAuthService.instance.signIn(
      role: role,
      village: village,
      district: district,
      organization: organization,
    );
    await _persistSession(token: result.token, user: result.user);
    return result;
  }
}
