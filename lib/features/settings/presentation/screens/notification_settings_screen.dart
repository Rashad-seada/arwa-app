import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/features/settings/presentation/widgets/settings_screen_template.dart';

// Provider for notification settings
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, Map<String, bool>>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<Map<String, bool>> {
  NotificationSettingsNotifier()
      : super({
          'email': true,
          'push': true,
          'marketing': false,
          'updates': true,
          'newFeatures': true,
          'tips': false,
          'reminders': true,
        });

  void toggleSetting(String key) {
    state = {
      ...state,
      key: !(state[key] ?? false),
    };
  }

  void updateSetting(String key, bool value) {
    state = {
      ...state,
      key: value,
    };
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return SettingsScreenTemplate(
      title: 'settings.notificationSettings'.tr(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title and description
            Text(
              'settings.manageNotifications'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'settings.notificationDescription'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Notification Channels section
            _buildSectionTitle(context, 'settings.notificationChannels'.tr()),
            const SizedBox(height: 16),
            
            _buildSettingsCard(
              context,
              children: [
                _buildSwitchTile(
                  context,
                  ref,
                  title: 'settings.emailNotifications'.tr(),
                  subtitle: 'settings.emailNotificationsDescription'.tr(),
                  value: notificationSettings['email'] ?? false,
                  settingKey: 'email',
                ),
                const Divider(),
                _buildSwitchTile(
                  context,
                  ref,
                  title: 'settings.pushNotifications'.tr(),
                  subtitle: 'settings.pushNotificationsDescription'.tr(),
                  value: notificationSettings['push'] ?? false,
                  settingKey: 'push',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Communication Categories section
            _buildSectionTitle(context, 'settings.communicationCategories'.tr()),
            const SizedBox(height: 16),
            
            _buildSettingsCard(
              context,
              children: [
                _buildSwitchTile(
                  context,
                  ref,
                  title: 'settings.marketingEmails'.tr(),
                  subtitle: 'settings.marketingEmailsDescription'.tr(),
                  value: notificationSettings['marketing'] ?? false,
                  settingKey: 'marketing',
                ),
                const Divider(),
                _buildSwitchTile(
                  context,
                  ref,
                  title: 'settings.appUpdates'.tr(),
                  subtitle: 'settings.appUpdatesDescription'.tr(),
                  value: notificationSettings['updates'] ?? false,
                  settingKey: 'updates',
                ),
                const Divider(),
                _buildSwitchTile(
                  context,
                  ref,
                  title: 'settings.newFeatures'.tr(),
                  subtitle: 'settings.newFeaturesDescription'.tr(),
                  value: notificationSettings['newFeatures'] ?? false,
                  settingKey: 'newFeatures',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // App Notifications section
            _buildSectionTitle(context, 'settings.appNotifications'.tr()),
            const SizedBox(height: 16),
            
            _buildSettingsCard(
              context,
              children: [
                _buildSwitchTile(
                  context,
                  ref,
                  title: 'settings.tipsAndTricks'.tr(),
                  subtitle: 'settings.tipsAndTricksDescription'.tr(),
                  value: notificationSettings['tips'] ?? false,
                  settingKey: 'tips',
                ),
                const Divider(),
                _buildSwitchTile(
                  context,
                  ref,
                  title: 'settings.reminders'.tr(),
                  subtitle: 'settings.remindersDescription'.tr(),
                  value: notificationSettings['reminders'] ?? false,
                  settingKey: 'reminders',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Note about device settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'settings.deviceSettingsNote'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
  
  Widget _buildSwitchTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required bool value,
    required String settingKey,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.muted,
        ),
      ),
      value: value,
      onChanged: (newValue) {
        ref.read(notificationSettingsProvider.notifier).updateSetting(settingKey, newValue);
      },
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
} 