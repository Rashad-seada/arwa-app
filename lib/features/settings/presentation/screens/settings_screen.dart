import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/config/locale_constants.dart';
import 'package:flutter_starter_package/core/providers/locale_provider.dart';
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
                          user?.name.isNotEmpty == true 
                              ? user!.name.substring(0, 1).toUpperCase() 
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
                              user?.name ?? 'User',
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
                              onPressed: () {},
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
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      context,
                      title: 'settings.changePassword'.tr(),
                      icon: Icons.lock_outline,
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      context,
                      title: 'settings.notificationSettings'.tr(),
                      icon: Icons.notifications_outlined,
                      onTap: () {},
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
                      trailing: _buildThemeSelector(context),
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
                      onTap: () {},
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
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      context,
                      title: 'settings.termsAndConditions'.tr(),
                      icon: Icons.description_outlined,
                      onTap: () {},
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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

  Widget _buildThemeSelector(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Theme.of(context).brightness == Brightness.light
              ? Center(
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Theme.of(context).brightness == Brightness.dark
              ? Center(
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.primary,
                  ),
                )
              : null,
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