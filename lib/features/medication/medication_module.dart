import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/medication_reminders_screen.dart';

class MedicationModule {
  static const String routePath = '/medication-reminders';
  
  static GoRoute routes() {
    return GoRoute(
      path: routePath,
      builder: (context, state) => const MedicationRemindersScreen(),
    );
  }
} 