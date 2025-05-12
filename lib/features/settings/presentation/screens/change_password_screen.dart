import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/core/widgets/password_field.dart';
import 'package:flutter_starter_package/core/widgets/primary_button.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';
import 'package:flutter_starter_package/features/settings/presentation/widgets/settings_screen_template.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _isSuccess = false;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        
        // Show success message
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScreenTemplate(
      title: 'settings.changePassword'.tr(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Password security icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title and description
              Text(
                'settings.updateYourPassword'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'settings.passwordSecurityDescription'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Success message
              if (_isSuccess) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'settings.passwordChangedSuccessfully'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Current Password
              PasswordField(
                label: 'settings.currentPassword'.tr(),
                hint: 'settings.enterCurrentPassword'.tr(),
                controller: _currentPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'errors.requiredField'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // New Password
              PasswordField(
                label: 'settings.newPassword'.tr(),
                hint: 'settings.enterNewPassword'.tr(),
                controller: _newPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'errors.requiredField'.tr();
                  }
                  if (value.length < 8) {
                    return 'errors.passwordLength'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm New Password
              PasswordField(
                label: 'settings.confirmNewPassword'.tr(),
                hint: 'settings.reEnterNewPassword'.tr(),
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'errors.requiredField'.tr();
                  }
                  if (value != _newPasswordController.text) {
                    return 'auth.passwordsDoNotMatch'.tr();
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              PrimaryButton(
                text: 'settings.updatePassword'.tr(),
                onPressed: _changePassword,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 