import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Updated with a more vibrant gradient palette
  static const Color primary = Color(0xFF5E60CE);
  static const Color primaryLight = Color(0xFF6930C3);
  static const Color primaryDark = Color(0xFF4E4B9E);
  static const Color accent = Color(0xFF64DFDF);

  // Neutral colors
  static const Color background = Color(0xFFF8F9FC);
  static const Color surface = Colors.white;
  static const Color foreground = Color(0xFF1F2033);
  static const Color muted = Color(0xFF777A9E);
  static const Color mutedLight = Color(0xFFE4E6F2);

  // Status colors - More vibrant
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF476F);
  static const Color info = Color(0xFF118AB2);

  // Dark mode colors - More elegant
  static const Color darkBackground = Color(0xFF121421);
  static const Color darkSurface = Color(0xFF1E2030);
  static const Color darkForeground = Color(0xFFE6E7F9);
  static const Color darkMuted = Color(0xFF8F90A6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF80FFDB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 