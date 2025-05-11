import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/register_stepper_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter_starter_package/features/home/home_module.dart';
import 'package:flutter_starter_package/features/settings/settings_module.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register-stepper',
        builder: (context, state) {
          final email = state.extra as String;
          return RegisterStepperScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final purpose = state.uri.queryParameters['purpose'] ?? 'verification';
          return OtpVerificationScreen(email: email, purpose: purpose);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(email: email, token: token);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeModule.homeScreen,
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsModule.settingsScreen,
      ),
    ],
  );
} 