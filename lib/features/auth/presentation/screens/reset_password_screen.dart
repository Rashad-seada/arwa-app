import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/core/widgets/password_field.dart';
import 'package:flutter_starter_package/core/widgets/primary_button.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    Key? key,
    required this.email,
    required this.token,
  }) : super(key: key);

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _resetSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final newPassword = _passwordController.text;
      
      try {
        final success = await ref.read(authProvider.notifier).resetPassword(
          widget.email,
          widget.token,
          newPassword,
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _resetSuccess = success;
          });
          
          if (success) {
            // Show success for a moment before navigating
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              context.go('/login');
            }
          }
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.foreground,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('auth.resetPassword'.tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'auth.resetPassword'.tr(),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new password for your account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 40),
                
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
                if (_resetSuccess) ...[
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
                            'auth.passwordChanged'.tr(),
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
                
                // Password field
                PasswordField(
                  label: 'auth.password'.tr(),
                  hint: 'Enter your new password',
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'errors.requiredField'.tr();
                    }
                    if (value.length < 6) {
                      return 'errors.passwordLength'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Confirm password field
                PasswordField(
                  label: 'auth.confirmPassword'.tr(),
                  hint: 'Confirm your new password',
                  controller: _confirmPasswordController,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'errors.requiredField'.tr();
                    }
                    if (value != _passwordController.text) {
                      return 'auth.passwordsDoNotMatch'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Reset button
                PrimaryButton(
                  text: 'auth.resetPassword'.tr(),
                  onPressed: _resetPassword,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                
                // Back to login
                if (!_resetSuccess)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'auth.signIn'.tr(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 