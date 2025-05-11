import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/core/widgets/otp_field.dart';
import 'package:flutter_starter_package/core/widgets/primary_button.dart';
import 'package:flutter_starter_package/core/widgets/themed_back_button.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String purpose;

  const OtpVerificationScreen({
    Key? key,
    required this.email,
    required this.purpose,
  }) : super(key: key);

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String _otp = '';
  int _resendCountdown = 60;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _isResendEnabled = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _isResendEnabled = true;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otp.length == 6) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final success = await ref.read(authProvider.notifier).verifyOtp(
          widget.email,
          _otp,
          widget.purpose,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (success) {
            if (widget.purpose == 'reset_password') {
              // Navigate to reset password screen
              context.push('/reset-password?email=${widget.email}&token=$_otp');
            } else {
              // Go to home or login depending on purpose
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
    } else {
      setState(() {
        _errorMessage = 'Please enter complete verification code';
      });
    }
  }

  Future<void> _resendOtp() async {
    if (!_isResendEnabled) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(authProvider.notifier).forgotPassword(widget.email);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          _startResendTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification code resent to ${widget.email}'),
              backgroundColor: AppColors.success,
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    final titleText = widget.purpose == 'reset_password'
        ? 'auth.resetPassword'.tr()
        : 'auth.verifyEmail'.tr();

    final descriptionText = widget.purpose == 'reset_password'
        ? 'Enter the 6-digit code sent to your email to reset your password'
        : 'Enter the 6-digit code sent to your email to verify your account';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const ThemedBackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'auth.codeHasBeenSentTo'.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
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

              // OTP field
              Center(
                child: OtpField(
                  length: 6,
                  onCompleted: (otp) {
                    setState(() {
                      _otp = otp;
                    });
                  },
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 32),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'auth.didntReceiveCode'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _isResendEnabled ? _resendOtp : null,
                    child: Text(
                      _isResendEnabled
                          ? 'auth.resend'.tr()
                          : 'auth.resendCode'.tr() + ' ($_resendCountdown)',
                      style: TextStyle(
                        color: _isResendEnabled
                            ? AppColors.primary
                            : AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Verify button
              PrimaryButton(
                text: 'common.verify'.tr(),
                onPressed: _verifyOtp,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 