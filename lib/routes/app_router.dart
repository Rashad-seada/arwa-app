import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/register_stepper_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:flutter_starter_package/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter_starter_package/features/settings/settings_module.dart';
import 'package:flutter_starter_package/features/glaucoma/glaucoma_module.dart';
import 'package:flutter_starter_package/features/medication/medication_module.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';
import 'package:flutter_starter_package/features/home/presentation/screens/home_screen.dart';

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
        builder: (context, state) => const HomeScreen(),
      ),
      // Settings routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsModule.settingsScreen,
      ),
      GoRoute(
        path: '/settings/account-information',
        builder: (context, state) => SettingsModule.accountInformationScreen,
      ),
      GoRoute(
        path: '/settings/change-password',
        builder: (context, state) => SettingsModule.changePasswordScreen,
      ),
      GoRoute(
        path: '/settings/notification-settings',
        builder: (context, state) => SettingsModule.notificationSettingsScreen,
      ),
      GoRoute(
        path: '/settings/about-app',
        builder: (context, state) => SettingsModule.aboutAppScreen,
      ),
      // Glaucoma route
      GlaucomaModule.routes(),
      // Medication reminder routes
      MedicationModule.routes(),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ProviderScope.containerOf(context).read(authProvider);
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      const isOnboardingComplete = true; // Replace with actual onboarding check if needed
      
      // Check if current path is an auth route
      final path = state.matchedLocation;
      final isOnAuthRoute = path == '/' || 
                           path == '/login' || 
                           path == '/register' || 
                           path == '/forgot-password' ||
                           path == '/reset-password' ||
                           path == '/otp-verification' ||
                           path == '/onboarding';
      
      // If not logged in and not on an auth route, redirect to login
      if (!isLoggedIn && !isOnAuthRoute) {
        return '/login';
      }
      
      // If logged in and on an auth route, redirect to home
      if (isLoggedIn && isOnAuthRoute && isOnboardingComplete) {
        return '/home';
      }
      
      // No redirect needed
      return null;
    },
  );
} 