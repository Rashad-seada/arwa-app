import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_package/features/auth/domain/models/user.dart';
import 'package:flutter_starter_package/features/auth/domain/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  authenticated,
  loading,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final user = await _authRepository.login(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      // Reset back to unauthenticated after error
      Future.delayed(const Duration(seconds: 1), () {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        );
      });
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final user = await _authRepository.register(name, email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      // Reset back to unauthenticated after error
      Future.delayed(const Duration(seconds: 1), () {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        );
      });
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authRepository.forgotPassword(email);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      // Reset back to unauthenticated after error
      Future.delayed(const Duration(seconds: 1), () {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        );
      });
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp, String purpose) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authRepository.verifyOtp(email, otp, purpose);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      // Reset back to unauthenticated after error
      Future.delayed(const Duration(seconds: 1), () {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        );
      });
      return false;
    }
  }

  Future<bool> resetPassword(String email, String token, String newPassword) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authRepository.resetPassword(email, token, newPassword);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      // Reset back to unauthenticated after error
      Future.delayed(const Duration(seconds: 1), () {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        );
      });
      return false;
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authRepository.logout();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final user = await _authRepository.signInWithGoogle();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      // Reset back to unauthenticated after error
      Future.delayed(const Duration(seconds: 1), () {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        );
      });
    }
  }
}

final authRepositoryProvider = StateProvider<AuthRepository>((ref) {
  throw UnimplementedError('Repository must be overridden');
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
}); 