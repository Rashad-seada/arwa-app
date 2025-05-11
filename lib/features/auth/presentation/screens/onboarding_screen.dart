import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;
  
  late final List<OnboardingPage> _pages;
  late AnimationController _backgroundController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    _pages = [
      OnboardingPage(
        title: 'onboarding.slideTitle1',
        description: 'onboarding.slideDescription1',
        color: AppColors.primary,
        icon: Icons.devices_rounded,
      ),
      OnboardingPage(
        title: 'onboarding.slideTitle2',
        description: 'onboarding.slideDescription2',
        color: AppColors.info,
        icon: Icons.architecture_rounded,
      ),
      OnboardingPage(
        title: 'onboarding.slideTitle3',
        description: 'onboarding.slideDescription3',
        color: AppColors.success,
        icon: Icons.auto_awesome_rounded,
      ),
    ];
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == _pages.length - 1;
    });
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _onSkipPressed() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Save that user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentPage];
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background layers
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundPainter(
                    progress: _backgroundController.value,
                    baseColor: _pages[_currentPage].color,
                  ),
                );
              },
            ),
          ),
          
          // Animated particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    progress: _particleController.value,
                    baseColor: _pages[_currentPage].color,
                  ),
                );
              },
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _onSkipPressed,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: _pages[_currentPage].color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'onboarding.skip'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          fontFamily: 'Almarai',
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .fade(duration: 400.ms, delay: 200.ms)
                .moveY(begin: -10, end: 0),
                
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(_pages[index], index);
                    },
                  ),
                ),
                
                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Page indicator
                      SizedBox(
                        height: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: _currentPage == index
                                    ? _pages[index].color
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Next button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentPage.color,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: currentPage.color.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLastPage
                                    ? 'onboarding.getStarted'.tr()
                                    : 'onboarding.next'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Almarai',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _isLastPage
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate(target: _isLastPage ? 1 : 0)
                      .shimmer(duration: 1200.ms, delay: 600.ms, color: Colors.white24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPageContent(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow effect
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                page.icon,
                size: 64,
                color: page.color,
              ),
            ),
          )
          .animate()
          .scale(delay: 300.ms, duration: 800.ms, curve: Curves.elasticOut,)
          .shimmer(delay: 400.ms, duration: 1800.ms, color: page.color.withOpacity(0.3)),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title.tr(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(delay: 300.ms, duration: 600.ms)
          .moveY(begin: 20, end: 0),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            page.description.tr(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(delay: 500.ms, duration: 600.ms)
          .moveY(begin: 20, end: 0),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}

class BackgroundPainter extends CustomPainter {
  final double progress;
  final Color baseColor;

  BackgroundPainter({required this.progress, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final darkColor = AppColors.darkBackground;
    
    // Create a gradient background with animated shapes
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = darkColor;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw animated blobs
    _drawAnimatedBlob(canvas, size, baseColor.withOpacity(0.2), progress, 0.3);
    _drawAnimatedBlob(canvas, size, baseColor.withOpacity(0.15), progress + 0.4, 0.5);
    
    // Create gradient overlay for depth
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: [
          baseColor.withOpacity(0.1),
          darkColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
    
    // Draw subtle grid lines
    _drawGrid(canvas, size, baseColor);
  }
  
  void _drawAnimatedBlob(Canvas canvas, Size size, Color color, double offset, double scale) {
    final center = Offset(
      size.width * (0.3 + 0.2 * math.sin(progress * math.pi * 2)),
      size.height * (0.4 + 0.2 * math.cos(progress * math.pi * 2 + offset)),
    );
    
    final blobSize = math.min(size.width, size.height) * scale;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    for (int i = 0; i < 360; i += 5) {
      final radian = i * math.pi / 180;
      final pulsate = 0.2 * math.sin(progress * math.pi * 4 + radian * 3);
      final radius = blobSize * (0.8 + pulsate);
      
      final x = center.dx + radius * math.cos(radian);
      final y = center.dy + radius * math.sin(radian);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawGrid(Canvas canvas, Size size, Color color) {
    final gridPaint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    const gridSize = 30.0;
    final offsetX = (progress * gridSize) % gridSize;
    final offsetY = (progress * gridSize * 0.7) % gridSize;
    
    // Vertical lines
    for (double x = offsetX; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    // Horizontal lines
    for (double y = offsetY; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  
  ParticlePainter({required this.progress, required this.baseColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // Fixed seed for deterministic behavior
    
    // Create particles
    final numParticles = 30;
    
    for (int i = 0; i < numParticles; i++) {
      // Particle properties
      final particleSize = 2.0 + rng.nextDouble() * 4.0;
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      
      // Animation properties
      final cycleOffset = rng.nextDouble() * math.pi * 2;
      final speed = 0.2 + rng.nextDouble() * 0.4;
      
      // Current position in animation
      final particleProgress = (progress + cycleOffset) % 1.0;
      final particleOpacity = 0.3 + 0.5 * math.sin(particleProgress * math.pi);
      
      // Movement pattern
      final dx = math.sin(particleProgress * math.pi * 2) * 10 * speed;
      final dy = math.cos(particleProgress * math.pi * 2) * 10 * speed;
      
      // Draw particle
      final paint = Paint()
        ..color = baseColor.withOpacity(particleOpacity)
        ..style = PaintingStyle.fill;
        
      // Particle glow
      canvas.drawCircle(
        Offset(x + dx, y + dy),
        particleSize * 2,
        Paint()
          ..color = baseColor.withOpacity(particleOpacity * 0.2)
          ..style = PaintingStyle.fill,
      );
        
      // Particle core
      canvas.drawCircle(
        Offset(x + dx, y + dy),
        particleSize,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 