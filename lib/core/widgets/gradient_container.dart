import 'package:flutter/material.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;

  const GradientContainer({
    Key? key,
    required this.child,
    this.gradient,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: boxShadow != null
            ? [boxShadow!]
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
      ),
      child: child,
    );
  }
} 