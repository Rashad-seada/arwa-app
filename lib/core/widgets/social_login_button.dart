import 'package:flutter/material.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SocialButtonType { google, apple, facebook }

class SocialLoginButton extends StatelessWidget {
  final SocialButtonType type;
  final VoidCallback onPressed;
  final String? text;
  final bool isLoading;
  
  const SocialLoginButton({
    Key? key,
    required this.type,
    required this.onPressed,
    this.text,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon(type);
    final buttonText = text ?? _getDefaultText(type);
    final buttonColor = _getButtonColor(type);
    final textColor = _getTextColor(type);
    final borderColor = _getBorderColor(type);
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1.5),
          // backgroundColor: buttonColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
          elevation: type == SocialButtonType.google ? 0.5 : 0,
          shadowColor: type == SocialButtonType.google ? Colors.black.withOpacity(0.2) : null,
        ),
        child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.muted),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: icon,
                ),
                const SizedBox(width: 12),
                Text(
                  buttonText,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _getIcon(SocialButtonType type) {
    switch (type) {
      case SocialButtonType.google:
        return SvgPicture.asset(
          'assets/images/google_logo.svg',
          width: 24,
          height: 24,
        );
      case SocialButtonType.apple:
        return const Icon(Icons.apple, color: Colors.black, size: 24);
      case SocialButtonType.facebook:
        return const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 24);
    }
  }

  String _getDefaultText(SocialButtonType type) {
    switch (type) {
      case SocialButtonType.google:
        return 'Continue with Google';
      case SocialButtonType.apple:
        return 'Continue with Apple';
      case SocialButtonType.facebook:
        return 'Continue with Facebook';
    }
  }

  Color _getButtonColor(SocialButtonType type) {
    switch (type) {
      case SocialButtonType.google:
      case SocialButtonType.apple:
      case SocialButtonType.facebook:
        return Colors.white;
    }
  }

  Color _getTextColor(SocialButtonType type) {
    switch (type) {
      case SocialButtonType.google:
        return const Color(0xFF3C4043); // Google's recommended text color
      case SocialButtonType.apple:
      case SocialButtonType.facebook:
        return AppColors.foreground;
    }
  }

  Color _getBorderColor(SocialButtonType type) {
    switch (type) {
      case SocialButtonType.google:
        return AppColors.primary;
      case SocialButtonType.apple:
      case SocialButtonType.facebook:
        return AppColors.mutedLight;
    }
  }
} 