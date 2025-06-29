import 'package:flutter_starter_package/core/config/supabase_config.dart';
import 'package:flutter_starter_package/features/auth/domain/models/user.dart';
import 'package:flutter_starter_package/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SupabaseAuthRepository implements AuthRepository {
  final _supabase = SupabaseConfig.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  
  // Convert Supabase user to app User model
  User _mapSupabaseUser(supabase.User supabaseUser) {
    return User(
      id: supabaseUser.id,
      full_name: supabaseUser.userMetadata?['full_name'] as String? ?? 'User',
      email: supabaseUser.email ?? '',
      photoUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
    );
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Login failed');
      }
      
      return _mapSupabaseUser(response.user!);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      );
      
      if (response.user == null) {
        throw Exception('Registration failed');
      }
      
      return _mapSupabaseUser(response.user!);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyOtp(String email, String otp, String purpose) async {
    try {
      // For email verification or password reset verification
      // Note: Supabase handles email verification automatically
      // This is primarily for password reset verification
      if (purpose == 'reset_password') {
        await _supabase.auth.verifyOTP(
          email: email,
          token: otp,
          type: supabase.OtpType.recovery,
        );
      }
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email, String token, String newPassword) async {
    try {
      // In Supabase, password reset is done after OTP verification
      await _supabase.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign In was canceled by user');
      }
      
      // Get auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a credential from the access token
      final response = await _supabase.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      if (response.user == null) {
        throw Exception('Google Sign In failed');
      }
      
      return _mapSupabaseUser(response.user!);
    } catch (e) {
      throw Exception('Google Sign In failed: ${e.toString()}');
    }
  }
  
  // Add Apple Sign In method
  Future<User> signInWithApple() async {
    try {
      // Get Apple credentials
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // Create a Supabase credential from the Apple ID token
      final response = await _supabase.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.apple,
        idToken: credential.identityToken!,
      );
      
      if (response.user == null) {
        throw Exception('Apple Sign In failed');
      }
      
      return _mapSupabaseUser(response.user!);
    } catch (e) {
      throw Exception('Apple Sign In failed: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      return null;
    }
    return _mapSupabaseUser(currentUser);
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
} 