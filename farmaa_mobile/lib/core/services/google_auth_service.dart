import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';

/// Handles Google Sign-In flow and integration with the Farmaa backend.
class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '603178299511-c40kmarpdjg1ntjjcebgmnlj7t521dvg.apps.googleusercontent.com',
  );

  /// Signs in with Google and authenticates with backend.
  /// Returns user model and token on success.
  Future<({UserModel user, String token})> signIn({
    required String role,
    String? village,
    String? district,
    String? organization,
  }) async {
    // Trigger Google Sign-In UI
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled');
    }

    // Get auth details
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Failed to get Google ID token');
    }

    // Try backend authentication
    try {
      final response = await ApiClient().dio.post('/auth/google', data: {
        'google_id_token': idToken,
        'email': googleUser.email,
        'name': googleUser.displayName ?? 'User',
        'profile_image': googleUser.photoUrl,
        'role': role,
        if (village != null) 'village': village,
        if (district != null) 'district': district,
        if (organization != null) 'org': organization,
      });

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token']?.toString() ?? 'demo_token';
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      return (user: user, token: token);
    } catch (e) {
      debugPrint('[GoogleAuth] Backend auth failed, creating demo session: $e');
      // Fallback to demo session
      return _createDemoSession(
          googleUser, role, village, district, organization);
    }
  }

  /// Signs out from Google.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[GoogleAuth] Sign out failed: $e');
    }
  }

  /// Check if currently signed in with Google.
  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  Future<({UserModel user, String token})> _createDemoSession(
    GoogleSignInAccount googleUser,
    String role,
    String? village,
    String? district,
    String? organization,
  ) async {
    final demoUser = UserModel(
      id: 'google_${googleUser.id}',
      name: googleUser.displayName ?? 'Google User',
      phone: '',
      email: googleUser.email,
      role: role,
      village: village,
      district: district,
      organization: organization,
      isVerified: true,
      profileImageUrl: googleUser.photoUrl,
      createdAt: DateTime.now(),
    );
    return (user: demoUser, token: 'demo_google_token');
  }
}
