import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/core/widgets/input_field.dart';
import 'package:flutter_starter_package/core/widgets/password_field.dart';
import 'package:flutter_starter_package/core/widgets/primary_button.dart';
import 'package:flutter_starter_package/core/widgets/social_login_button.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      ref.read(authProvider.notifier).login(email, password);
    }
  }
  
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes
    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/home');
      } else if (next.status == AuthStatus.error) {
        setState(() {
          _isLoading = false;
          _isGoogleLoading = false;
          _errorMessage = next.errorMessage;
        });
      } else if (next.status == AuthStatus.loading) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and description at the top
                Text(
                  'auth.login'.tr(),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'auth.loginDescription'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Social login at the top
                SocialLoginButton(
                  type: SocialButtonType.google,
                  onPressed: _signInWithGoogle,
                  text: 'auth.continueWithGoogle'.tr(),
                  isLoading: _isGoogleLoading,
                ),
                const SizedBox(height: 24),
                
                // Or divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.mutedLight,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'auth.orSignInWithEmail'.tr(),
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.mutedLight,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
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
                
                // Email field
                InputField(
                  label: 'auth.emailAddress'.tr(),
                  hint: 'auth.emailHint'.tr(),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'errors.requiredField'.tr();
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'errors.invalidEmail'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Password field
                PasswordField(
                  label: 'auth.password'.tr(),
                  hint: 'auth.passwordHint'.tr(),
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'errors.requiredField'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      'auth.forgotPassword'.tr(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Login button
                PrimaryButton(
                  text: 'auth.signIn'.tr(),
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'auth.dontHaveAccount'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        'auth.signUp'.tr(),
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