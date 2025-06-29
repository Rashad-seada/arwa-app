import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/eye_scan_screen.dart';

/// Module for glaucoma-related features
class GlaucomaModule {
  const GlaucomaModule();
  
  static const String routePath = '/eye-scans';
  
  // Provide access to the eye scan screen
  Widget get eyeScanScreen => const EyeScanScreen();
  
  // Static method for routes
  static GoRoute routes() {
    return GoRoute(
      path: routePath,
      builder: (context, state) => const EyeScanScreen(),
    );
  }
} 