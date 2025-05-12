import 'package:flutter/material.dart';
import 'package:flutter_starter_package/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_starter_package/features/settings/presentation/screens/account_information_screen.dart';
import 'package:flutter_starter_package/features/settings/presentation/screens/change_password_screen.dart';
import 'package:flutter_starter_package/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:flutter_starter_package/features/settings/presentation/screens/about_app_screen.dart';

/// Settings Module
/// 
/// This class serves as the entry point for the Settings feature module.
/// It exports the main screen and any other components that might be needed
/// by other parts of the application.
class SettingsModule {
  /// The main screen of the Settings module
  static const Widget settingsScreen = SettingsScreen();
  
  /// Account information screen
  static const Widget accountInformationScreen = AccountInformationScreen();
  
  /// Change password screen
  static const Widget changePasswordScreen = ChangePasswordScreen();
  
  /// Notification settings screen
  static const Widget notificationSettingsScreen = NotificationSettingsScreen();
  
  /// About app screen
  static const Widget aboutAppScreen = AboutAppScreen();
} 