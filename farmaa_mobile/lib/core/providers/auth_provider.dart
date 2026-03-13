import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// ── Auth State ────────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ── Auth Notifier ─────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Start with a loading state so the router waits for session restore
    _loadPersistedUser();
    return const AuthState(isLoading: true);
  }

  Future<void> _loadPersistedUser() async {
    try {
      final user = await AuthService.instance
          .getPersistedUser()
          .timeout(const Duration(seconds: 2));
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      debugPrint('[AuthNotifier] Session restore failed or timed out: $e');
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthService.instance.sendOtp(phone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp({
    required String phone,
    required String otp,
    required String role,
    required String name,
    String? village,
    String? district,
    String? organization,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await AuthService.instance.verifyOtp(
        phone: phone,
        otp: otp,
        role: role,
        name: name,
        village: village,
        district: district,
        organization: organization,
      );
      state = AuthState(user: result.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Don't let a hanging network call block the logout transition.
      // We give the backend 1 second to respond, then we clear state regardless.
      await ref
          .read(authProvider.notifier)
          .refreshProfile() // Just a placeholder check
          .timeout(const Duration(milliseconds: 100)); // Very aggressive

      await AuthService.instance.logout().timeout(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('[AuthNotifier] Logout network call failed or timed out: $e');
    } finally {
      state = const AuthState();
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await AuthService.instance.getProfile();
      state = AuthState(user: user, isLoading: false);
    } catch (_) {}
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? village,
    String? district,
    String? organization,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await AuthService.instance.updateProfile(
        name: name,
        phone: phone,
        village: village,
        district: district,
        organization: organization,
      );
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> loginWithGoogle({
    required String role,
    String? village,
    String? district,
    String? organization,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await AuthService.instance.loginWithGoogle(
        role: role,
        village: village,
        district: district,
        organization: organization,
      );
      state = AuthState(user: result.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Signal that the splash animation is complete.
final splashFinishedProvider = StateProvider<bool>((ref) => false);

/// Convenience provider: the current authenticated user (or null).
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
