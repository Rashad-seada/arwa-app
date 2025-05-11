import 'package:flutter/material.dart';

/// A back button that automatically adapts to the current theme.
/// 
/// This widget provides a consistent back button appearance across the app,
/// with proper theme-aware colors for both light and dark modes.
class ThemedBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ThemedBackButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current theme's foreground color
    final color = Theme.of(context).colorScheme.onBackground;
    
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: color,
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }
} 