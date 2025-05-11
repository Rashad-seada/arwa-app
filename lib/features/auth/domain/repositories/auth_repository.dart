import 'package:flutter_starter_package/features/auth/domain/models/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<User> signInWithGoogle();
  Future<void> forgotPassword(String email);
  Future<void> verifyOtp(String email, String otp, String purpose);
  Future<void> resetPassword(String email, String token, String newPassword);
  Future<User?> getCurrentUser();
  Future<void> logout();
} 