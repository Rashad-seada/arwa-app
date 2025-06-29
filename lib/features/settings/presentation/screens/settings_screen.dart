import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/config/locale_constants.dart';
import 'package:flutter_starter_package/core/providers/locale_provider.dart';
import 'package:flutter_starter_package/core/providers/theme_provider.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/core/widgets/gradient_container.dart';
import 'package:flutter_starter_package/core/widgets/themed_back_button.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentLocale = context.locale;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const ThemedBackButton(),
        title: Text('settings.title'.tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section
                GradientContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Text(
                          user?.full_name.isNotEmpty == true
                              ? user!.full_name.substring(0, 1).toUpperCase()
                              : 'U',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.full_name ?? 'User',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'email@example.com',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/settings/account-information'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('settings.editProfile'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Settings sections
                Text(
                  'settings.accountSettings'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                _buildSettingsGroup(
                  context,
                  [
                    _buildSettingItem(
                      context,
                      title: 'settings.accountInformation'.tr(),
                      icon: Icons.person_outline,
                      onTap: () => context.go('/settings/account-information'),
                    ),
                    _buildSettingItem(
                      context,
                      title: 'settings.changePassword'.tr(),
                      icon: Icons.lock_outline,
                      onTap: () => context.go('/settings/change-password'),
                    ),
                    _buildSettingItem(
                      context,
                      title: 'settings.notificationSettings'.tr(),
                      icon: Icons.notifications_outlined,
                      onTap: () => context.go('/settings/notification-settings'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'settings.appSettings'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                _buildSettingsGroup(
                  context,
                  [
                    _buildSettingItem(
                      context,
                      title: 'settings.theme'.tr(),
                      icon: Icons.palette_outlined,
                      trailing: Container(
                        width: 160,
                        child: _buildThemeSelector(context, ref),
                      ),
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      context,
                      title: 'settings.language'.tr(),
                      icon: Icons.language_outlined,
                      trailing: _buildLanguageSelector(context, ref),
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      context,
                      title: 'settings.aboutApp'.tr(),
                      icon: Icons.info_outline,
                      onTap: () => context.go('/settings/about-app'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'settings.privacyAndSecurity'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                _buildSettingsGroup(
                  context,
                  [
                    _buildSettingItem(
                      context,
                      title: 'settings.privacyPolicy'.tr(),
                      icon: Icons.privacy_tip_outlined,
                      onTap: () {
                        // Show a dialog or navigate to privacy policy page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Privacy Policy coming soon'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      context,
                      title: 'settings.termsAndConditions'.tr(),
                      icon: Icons.description_outlined,
                      onTap: () {
                        // Show a dialog or navigate to terms & conditions page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Terms & Conditions coming soon'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Logout button
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'auth.logout'.tr(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // App version
                Center(
                  child: Text(
                    '${'settings.appVersion'.tr()} 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? value,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final hasTrailing = trailing != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasTrailing ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              if (trailing != null) trailing,
              if (value == null && trailing == null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      children: [
        // Light theme option
        _buildThemeOption(
          context,
          label: 'settings.themeLight'.tr(),
          isSelected: themeMode == ThemeMode.light,
          color: AppColors.background,
          icon: Icons.light_mode,
          onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
        ),
        
        // Dark theme option
        _buildThemeOption(
          context,
          label: 'settings.themeDark'.tr(),
          isSelected: themeMode == ThemeMode.dark,
          color: AppColors.darkBackground,
          icon: Icons.dark_mode,
          onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
        ),
        
        // System theme option
        _buildThemeOption(
          context,
          label: 'settings.themeSystem'.tr(),
          isSelected: themeMode == ThemeMode.system,
          color: Colors.transparent,
          icon: Icons.settings_suggest,
          isGradient: true,
          onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
        ),
      ],
    );
  }
  
  // Theme change feedback
  void _showThemeChangeFeedback(BuildContext context, ThemeMode mode) {
    final String message = mode == ThemeMode.light 
        ? 'settings.themeLight'.tr() 
        : mode == ThemeMode.dark 
            ? 'settings.themeDark'.tr() 
            : 'settings.themeSystem'.tr();
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${message} ${'settings.themeApplied'.tr()}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
  
  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Color color,
    required IconData icon,
    bool isGradient = false,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            onTap();
            if (!isSelected) {
              // Show feedback when theme changes
              final ThemeMode newMode;
              if (label == 'settings.themeLight'.tr()) {
                newMode = ThemeMode.light;
              } else if (label == 'settings.themeDark'.tr()) {
                newMode = ThemeMode.dark;
              } else {
                newMode = ThemeMode.system;
              }
              _showThemeChangeFeedback(context, newMode);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isGradient ? null : color,
              gradient: isGradient
                  ? LinearGradient(
                      colors: [AppColors.background, AppColors.darkBackground],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? AppColors.primary 
                    : (isGradient 
                        ? AppColors.muted 
                        : (color == AppColors.darkBackground 
                            ? Colors.white.withOpacity(0.8) 
                            : AppColors.muted)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primary : AppColors.muted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref) {
    final currentLocale = context.locale;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            await context.setLocale(LocaleConstants.enLocale);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: currentLocale.languageCode == 'en'
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: currentLocale.languageCode == 'en'
                    ? AppColors.primary
                    : AppColors.muted.withOpacity(0.3),
              ),
            ),
            child: Text(
              'settings.english'.tr(),
              style: TextStyle(
                color: currentLocale.languageCode == 'en'
                    ? AppColors.primary
                    : AppColors.muted,
                fontWeight: currentLocale.languageCode == 'en'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () async {
            await context.setLocale(LocaleConstants.arLocale);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: currentLocale.languageCode == 'ar'
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: currentLocale.languageCode == 'ar'
                    ? AppColors.primary
                    : AppColors.muted.withOpacity(0.3),
              ),
            ),
            child: Text(
              'settings.arabic'.tr(),
              style: TextStyle(
                color: currentLocale.languageCode == 'ar'
                    ? AppColors.primary
                    : AppColors.muted,
                fontWeight: currentLocale.languageCode == 'ar'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 