import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showTitle;
  final Color? backgroundColor;
  final Color? iconColor;
  
  const AppLogo({
    Key? key,
    this.size = 80,
    this.showTitle = true,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(size / 5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.start_rounded,
            size: size * 0.66,
            color: iconColor ?? AppColors.primary,
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 16),
          Text(
            'app.title'.tr(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
} 