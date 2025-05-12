import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/features/settings/presentation/widgets/settings_screen_template.dart';

class AboutAppScreen extends ConsumerWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsScreenTemplate(
      title: 'settings.aboutApp'.tr(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo and name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'FS',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'app.title'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'v1.0.0', // App version
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // App description
            _buildSectionTitle(context, 'settings.description'.tr()),
            const SizedBox(height: 16),
            Text(
              'settings.appDescription'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Features
            _buildSectionTitle(context, 'settings.features'.tr()),
            const SizedBox(height: 16),
            _buildFeaturesList(context),
            const SizedBox(height: 24),
            
            // Credits
            _buildSectionTitle(context, 'settings.credits'.tr()),
            const SizedBox(height: 16),
            _buildCreditsCard(context),
            const SizedBox(height: 24),
            
            // Contact information
            _buildSectionTitle(context, 'settings.contactInformation'.tr()),
            const SizedBox(height: 16),
            _buildContactInfo(context),
            const SizedBox(height: 32),
            
            Center(
              child: Text(
                'settings.allRightsReserved'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
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
  
  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      'settings.featureCleanArchitecture'.tr(),
      'settings.featureMultiLanguage'.tr(),
      'settings.featureDarkMode'.tr(),
      'settings.featureAuth'.tr(),
      'settings.featureModernUI'.tr(),
    ];
    
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getFeatureIcon(index),
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            title: Text(
              features[index],
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
  
  IconData _getFeatureIcon(int index) {
    switch (index) {
      case 0:
        return Icons.architecture;
      case 1:
        return Icons.language;
      case 2:
        return Icons.dark_mode;
      case 3:
        return Icons.security;
      case 4:
        return Icons.design_services;
      default:
        return Icons.star;
    }
  }
  
  Widget _buildCreditsCard(BuildContext context) {
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
        children: [
          _buildCreditItem(
            context,
            role: 'settings.leadDeveloper'.tr(),
            name: 'John Doe',
          ),
          const Divider(),
          _buildCreditItem(
            context,
            role: 'settings.designer'.tr(),
            name: 'Jane Smith',
          ),
          const Divider(),
          _buildCreditItem(
            context,
            role: 'settings.productManager'.tr(),
            name: 'Robert Johnson',
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreditItem(BuildContext context, {required String role, required String name}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactInfo(BuildContext context) {
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
        children: [
          _buildContactItem(
            context,
            icon: Icons.email_outlined,
            title: 'settings.email'.tr(),
            value: 'support@example.com',
          ),
          const Divider(),
          _buildContactItem(
            context,
            icon: Icons.language,
            title: 'settings.website'.tr(),
            value: 'www.example.com',
          ),
          const Divider(),
          _buildContactItem(
            context,
            icon: Icons.location_on_outlined,
            title: 'settings.address'.tr(),
            value: '123 App Street, San Francisco, CA',
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 