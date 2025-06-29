import 'package:flutter_starter_package/features/auth/domain/models/user.dart';
import 'package:flutter_starter_package/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

// In a real app, this would call APIs, but we'll mock it for simplicity
class AuthRepositoryImpl implements AuthRepository {
  static const String _userKey = 'current_user';
  
  // Mock user data
  final Map<String, User> _users = {};
  
  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  @override
  Future<User> login(String email, String password) async {
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if user exists and password matches
    // In a real app, we'd make an API call and handle proper auth
    final normalizedEmail = email.toLowerCase();
    if (_users.containsKey(normalizedEmail)) {
      // In a real app, we would properly verify passwords
      final user = _users[normalizedEmail]!;
      
      // Save to shared preferences
      await _saveUserToPrefs(user);
      
      return user;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  @override
  Future<User> register(String name, String email, String password) async {
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));
    
    final normalizedEmail = email.toLowerCase();
    
    // Check if user already exists
    if (_users.containsKey(normalizedEmail)) {
      throw Exception('User already exists');
    }
    
    // Create a new user
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: normalizedEmail,
      full_name: name,
    );
    
    _users[normalizedEmail] = user;
    
    // Save to shared preferences
    await _saveUserToPrefs(user);
    
    return user;
  }

  @override
  Future<void> forgotPassword(String email) async {
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));
    
    final normalizedEmail = email.toLowerCase();
    
    if (!_users.containsKey(normalizedEmail)) {
      throw Exception('User does not exist');
    }
    
    // In a real app, this would send an email with an OTP
    print('Sending OTP to $email');
  }

  @override
  Future<void> verifyOtp(String email, String otp, String purpose) async {
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, we would verify the OTP with the backend
    if (otp != '123456') {  // Mock OTP check
      throw Exception('Invalid OTP');
    }
    
    // For demo purposes, just print success
    print('OTP verified for $email for purpose: $purpose');
  }

  @override
  Future<void> resetPassword(String email, String token, String newPassword) async {
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));
    
    final normalizedEmail = email.toLowerCase();
    
    if (!_users.containsKey(normalizedEmail)) {
      throw Exception('User does not exist');
    }
    
    // In a real app, we would verify the token and update the password in the backend
    print('Password reset for $email');
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign In was canceled by user');
      }
      
      // In a real app, you would send this token to your backend to verify
      // For this example, we'll just create a user based on Google account info
      final normalizedEmail = googleUser.email.toLowerCase();
      
      // Check if this Google user has signed in before
      User user;
      if (_users.containsKey(normalizedEmail)) {
        user = _users[normalizedEmail]!;
      } else {
        // Create a new user with Google info
        user = User(
          id: googleUser.id,
          full_name: googleUser.displayName ?? 'Google User',

          email: normalizedEmail,
        );
        _users[normalizedEmail] = user;
      }
      
      // Save to shared preferences
      await _saveUserToPrefs(user);
      
      return user;
    } catch (e) {
      throw Exception('Google Sign In failed: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson == null) {
      return null;
    }
    
    return User.fromJson(jsonDecode(userJson));
  }

  @override
  Future<void> logout() async {
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Also sign out from Google if signed in
    await _googleSignIn.signOut();
    
    // Clear local user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
  
  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
} 