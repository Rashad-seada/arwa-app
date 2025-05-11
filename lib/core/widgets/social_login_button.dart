import 'package:flutter/material.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'dart:math' as math;

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
        return const GoogleLogo();
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

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // color: Colors.white,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Multi-colored G
            SizedBox(
              width: 18,
              height: 18,
              child: CustomPaint(
                painter: _GoogleGPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Colors from Google's brand guidelines
    const blue = Color(0xFF4285F4);
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);

    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw simplified Google G
    final path = Path();

    // Draw blue half-circle (right side)
    paint.color = blue;
    path.moveTo(width * 0.75, height * 0.5);
    path.arcTo(
      Rect.fromLTWH(width * 0.25, 0, width * 0.75, height),
      -math.pi / 2,
      math.pi,
      false,
    );
    path.lineTo(width * 0.75, height * 0.5);
    path.close();
    canvas.drawPath(path, paint);

    // Draw red quarter-circle (top-left)
    paint.color = red;
    path.reset();
    path.moveTo(width * 0.5, height * 0.25);
    path.arcTo(
      Rect.fromLTWH(0, 0, width, height * 0.5),
      math.pi,
      math.pi / 2,
      false,
    );
    path.lineTo(width * 0.5, height * 0.25);
    path.close();
    canvas.drawPath(path, paint);

    // Draw yellow quarter-circle (bottom-left)
    paint.color = yellow;
    path.reset();
    path.moveTo(width * 0.25, height * 0.5);
    path.arcTo(
      Rect.fromLTWH(0, height * 0.5, width * 0.5, height * 0.5),
      -math.pi / 2,
      math.pi / 2,
      false,
    );
    path.lineTo(width * 0.25, height * 0.5);
    path.close();
    canvas.drawPath(path, paint);

    // Draw green quarter-circle (bottom-right)
    paint.color = green;
    path.reset();
    path.moveTo(width * 0.75, height * 0.75);
    path.arcTo(
      Rect.fromLTWH(width * 0.5, height * 0.5, width * 0.5, height * 0.5),
      math.pi,
      math.pi / 2,
      false,
    );
    path.lineTo(width * 0.75, height * 0.75);
    path.close();
    canvas.drawPath(path, paint);

    // White center
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(width * 0.5, height * 0.5),
      width * 0.25,
      paint,
    );

    // Blue bar on right
    paint.color = blue;
    canvas.drawRect(
      Rect.fromLTWH(width * 0.5, height * 0.4, width * 0.5, height * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 