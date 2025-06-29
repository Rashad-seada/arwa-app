import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/core/widgets/input_field.dart';
import 'package:flutter_starter_package/core/widgets/primary_button.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';
import 'package:flutter_starter_package/features/settings/presentation/widgets/settings_screen_template.dart';

class AccountInformationScreen extends ConsumerStatefulWidget {
  const AccountInformationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AccountInformationScreen> createState() => _AccountInformationScreenState();
}

class _AccountInformationScreenState extends ConsumerState<AccountInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController; // We'll use a placeholder value for this
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.full_name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    // Use email as placeholder for username since it's not in the User model
    _usernameController = TextEditingController(text: _generateUsernamePlaceholder(user?.email ?? ''));
  }

  // Generate a username from email (everything before the @ symbol)
  String _generateUsernamePlaceholder(String email) {
    return email.split('@').first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values when canceling edit
        final user = ref.read(authProvider).user;
        _nameController.text = user?.full_name ?? '';
        _emailController.text = user?.email ?? '';
        _usernameController.text = _generateUsernamePlaceholder(user?.email ?? '');
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Here you would call the API to update user info
        // For now, we'll just simulate a delay
        await Future.delayed(const Duration(seconds: 1));
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('settings.profileUpdatedSuccessfully'.tr()),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _isLoading = false;
            _isEditing = false;
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
    final user = ref.watch(authProvider).user;

    return SettingsScreenTemplate(
      title: 'settings.accountInformation'.tr(),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit),
          onPressed: _toggleEditing,
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        user?.full_name.isNotEmpty == true
                          ? user!.full_name.substring(0, 1).toUpperCase()
                          : 'U',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
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
              
              // Name Field
              InputField(
                label: 'common.name'.tr(),
                hint: 'auth.fullNameHint'.tr(),
                controller: _nameController,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'errors.requiredField'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Username Field
              InputField(
                label: 'auth.username'.tr(),
                hint: 'auth.usernameHint'.tr(),
                controller: _usernameController,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'errors.requiredField'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email Field (usually not editable)
              InputField(
                label: 'common.email'.tr(),
                hint: 'auth.emailHint'.tr(),
                controller: _emailController,
                enabled: false, // Email is typically not editable
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 32),
              
              // Save Button (only visible in edit mode)
              if (_isEditing)
                PrimaryButton(
                  text: 'common.save'.tr(),
                  onPressed: _saveChanges,
                  isLoading: _isLoading,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 