import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/core/widgets/input_field.dart';
import 'package:flutter_starter_package/core/widgets/password_field.dart';
import 'package:flutter_starter_package/core/widgets/primary_button.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class RegisterStepperScreen extends ConsumerStatefulWidget {
  final String email;
  
  const RegisterStepperScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  ConsumerState<RegisterStepperScreen> createState() => _RegisterStepperScreenState();
}

class _RegisterStepperScreenState extends ConsumerState<RegisterStepperScreen> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;
  bool _isCompleted = false;
  
  late AnimationController _confettiController;
  late AnimationController _checkmarkController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confettiController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep == 0) {
        setState(() {
          _currentStep = 1;
          _errorMessage = null;
        });
      } else if (_currentStep == 1) {
        // Explicitly validate password before proceeding
        final password = _passwordController.text;
        if (password.isEmpty) {
          setState(() {
            _errorMessage = 'Password is required';
          });
          return;
        }
        
        if (password.length < 8) {
          setState(() {
            _errorMessage = 'Password must be at least 8 characters';
          });
          return;
        }
        
        if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password)) {
          setState(() {
            _errorMessage = 'Password must include uppercase, lowercase, number and special character';
          });
          return;
        }
        
        _register();
      }
    }
  }
  
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final name = _usernameController.text.trim();
      final email = widget.email;
      final password = _passwordController.text;
      
      await ref.read(authProvider.notifier).register(name, email, password);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 2;
          _isCompleted = true;
        });
        
        // Start animations
        _confettiController.forward();
        _checkmarkController.forward();
        
        // Navigate to home after delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.go('/home');
          }
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
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Improved stepper indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      _buildStepperItem(0, 'Username'),
                      _buildStepperConnector(_currentStep >= 1),
                      _buildStepperItem(1, 'Password'),
                      _buildStepperConnector(_currentStep >= 2),
                      _buildStepperItem(2, 'Complete'),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and content based on current step
                          if (_currentStep == 0) _buildUsernameStep(),
                          if (_currentStep == 1) _buildPasswordStep(),
                          if (_currentStep == 2) _buildCompletedStep(),
                          
                          // Error message
                          if (_errorMessage != null && !_isCompleted) ...[
                            const SizedBox(height: 24),
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
                          ],
                          
                          if (!_isCompleted) ...[
                            const SizedBox(height: 32),
                            PrimaryButton(
                              text: _currentStep == 0 
                                ? 'common.continue'.tr() 
                                : 'auth.signUp'.tr(),
                              onPressed: _nextStep,
                              isLoading: _isLoading,
                              icon: _currentStep == 0 
                                ? Icons.arrow_forward 
                                : Icons.check_circle_outline,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Confetti animation overlay for completed step
            if (_isCompleted)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ConfettiPainter(
                          progress: _confettiController.value,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Improved stepper item
  Widget _buildStepperItem(int step, String label) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step || (_currentStep == step && _isCompleted);
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.mutedLight,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted 
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.muted,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Almarai',
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.tr(),
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.muted,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Almarai',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepperConnector(bool isActive) {
    return Container(
      height: 2,
      width: 30,
      color: isActive ? AppColors.primary : AppColors.mutedLight,
      margin: const EdgeInsets.only(bottom: 24),
    );
  }
  
  // Step 1: Username
  Widget _buildUsernameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.createUsername'.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Almarai',
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .moveY(begin: 10, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          'auth.usernameDescription'.tr(),
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 16,
            fontFamily: 'Almarai',
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 100.ms)
        .moveY(begin: 10, end: 0),
        
        const SizedBox(height: 32),
        
        InputField(
          label: 'auth.username'.tr(),
          hint: 'auth.usernameHint'.tr(),
          controller: _usernameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'errors.requiredField'.tr();
            }
            return null;
          },
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .moveY(begin: 10, end: 0),
      ],
    );
  }
  
  // Step 2: Password
  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.createPassword'.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Almarai',
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .moveY(begin: 10, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          'auth.passwordRequirements'.tr(),
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 16,
            fontFamily: 'Almarai',
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 100.ms)
        .moveY(begin: 10, end: 0),
        
        const SizedBox(height: 32),
        
        // Change to manual password field construction for more control
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'auth.password'.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true, // Always start obscured
              decoration: InputDecoration(
                hintText: 'auth.passwordHint'.tr(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.visibility_outlined),
                  onPressed: () {
                    // Toggle password visibility logic would go here
                  },
                ),
              ),
              onChanged: (value) {
                // Trigger UI update when password changes to update strength indicator
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'errors.requiredField'.tr();
                }
                if (value.length < 8) {
                  return 'errors.passwordLength'.tr();
                }
                if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
                  return 'errors.weakPassword'.tr();
                }
                return null;
              },
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .moveY(begin: 10, end: 0),
        
        const SizedBox(height: 24),
        
        _buildPasswordStrengthIndicator()
        .animate()
        .fadeIn(duration: 500.ms, delay: 400.ms),
      ],
    );
  }
  
  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    
    // Password strength checks
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= 8;
    
    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasNumber) strength++;
    if (hasSpecial) strength++;
    if (hasMinLength) strength++;
    
    Color strengthColor = AppColors.error;
    String strengthText = 'auth.passwordStrengthWeak'.tr();
    
    if (strength >= 5) {
      strengthColor = AppColors.success;
      strengthText = 'auth.passwordStrengthStrong'.tr();
    } else if (strength >= 3) {
      strengthColor = Colors.orange;
      strengthText = 'auth.passwordStrengthMedium'.tr();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'auth.passwordStrength'.tr() + ': ',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                fontFamily: 'Almarai',
              ),
            ),
            Text(
              strengthText,
              style: TextStyle(
                color: strengthColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Almarai',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Strength bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.mutedLight,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Flexible(
                flex: strength,
                child: Container(
                  decoration: BoxDecoration(
                    color: strengthColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Flexible(
                flex: 5 - strength,
                child: Container(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Requirement checks
        _buildRequirementRow(hasMinLength, 'auth.passwordRequirement1'.tr()),
        _buildRequirementRow(hasUppercase, 'auth.passwordRequirement2'.tr()),
        _buildRequirementRow(hasLowercase, 'auth.passwordRequirement3'.tr()),
        _buildRequirementRow(hasNumber, 'auth.passwordRequirement4'.tr()),
        _buildRequirementRow(hasSpecial, 'auth.passwordRequirement5'.tr()),
      ],
    );
  }
  
  Widget _buildRequirementRow(bool isMet, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? AppColors.success : AppColors.muted,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? AppColors.foreground : AppColors.muted,
              fontSize: 14,
              fontFamily: 'Almarai',
            ),
          ),
        ],
      ),
    );
  }
  
  // Step 3: Completed
  Widget _buildCompletedStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        
        // Animated checkmark
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _checkmarkController,
              builder: (context, child) {
                return CustomPaint(
                  painter: CheckmarkPainter(
                    progress: _checkmarkController.value,
                    color: AppColors.success,
                    strokeWidth: 4,
                  ),
                  size: const Size(80, 80),
                );
              },
            ),
          ),
        )
        .animate()
        .scale(duration: 400.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 40),
        
        Text(
          'auth.accountCreated'.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Almarai',
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 400.ms)
        .moveY(begin: 10, end: 0),
        
        const SizedBox(height: 16),
        
        Text(
          'auth.accountCreatedDescription'.tr(),
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 16,
            fontFamily: 'Almarai',
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms),
      ],
    );
  }
}

// Custom painter for confetti animation
class ConfettiPainter extends CustomPainter {
  final double progress;
  
  ConfettiPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // Fixed seed for consistent pattern
    
    // Generate confetti pieces
    const int numPieces = 150;
    
    for (int i = 0; i < numPieces; i++) {
      // Calculate position
      final x = rng.nextDouble() * size.width;
      final initialY = -50.0 - rng.nextDouble() * 100.0;
      final finalY = size.height * rng.nextDouble();
      
      // Stagger the animation
      final startTime = rng.nextDouble() * 0.3; // Start within first 30% of animation
      final endTime = 0.7 + rng.nextDouble() * 0.3; // End within last 30% of animation
      
      // Calculate current position based on progress
      double currentProgress = math.max(0, math.min(1, (progress - startTime) / (endTime - startTime)));
      
      // Add some curve to the motion
      final curvedProgress = Curves.easeInOut.transform(currentProgress);
      
      // Final position with swaying
      final swayAmount = 30.0 + rng.nextDouble() * 70.0;
      final swayOffset = math.sin(progress * math.pi * 2 * (rng.nextDouble() + 1)) * swayAmount;
      
      final currentY = initialY + (finalY - initialY) * curvedProgress;
      final currentX = x + swayOffset * curvedProgress;
      
      // Skip if not yet visible or already disappeared
      if (currentProgress <= 0 || currentProgress >= 1) continue;
      
      // Random properties for each piece
      final pieceSize = 5.0 + rng.nextDouble() * 10.0;
      final angle = progress * math.pi * 4 * (rng.nextDouble() + 0.5);
      final opacity = math.sin(currentProgress * math.pi) * 0.8 + 0.2;
      
      // Random color
      final colors = [
        AppColors.primary, AppColors.accent, AppColors.success, AppColors.warning, 
        AppColors.error, AppColors.info, AppColors.primaryLight, AppColors.primaryDark
      ];
      // Using withAlpha instead of withOpacity
      final alphaValue = (opacity * 255).round();
      final color = colors[rng.nextInt(colors.length)].withAlpha(alphaValue);
      
      // Draw the confetti piece
      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(angle);
      
      // Shape variation
      final shape = rng.nextInt(3);
      
      final paint = Paint()..color = color;
      
      if (shape == 0) {
        // Rectangle
        canvas.drawRect(Rect.fromLTWH(-pieceSize/2, -pieceSize/2, pieceSize, pieceSize), paint);
      } else if (shape == 1) {
        // Circle
        canvas.drawCircle(Offset.zero, pieceSize/2, paint);
      } else {
        // Triangle
        final path = Path()
          ..moveTo(0, -pieceSize/2)
          ..lineTo(-pieceSize/2, pieceSize/2)
          ..lineTo(pieceSize/2, pieceSize/2)
          ..close();
        canvas.drawPath(path, paint);
      }
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Custom painter for checkmark animation
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  
  CheckmarkPainter({
    required this.progress, 
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Draw circle first
    final circlePath = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
      
    final circleProgress = math.min(1.0, progress * 2); // First half of animation
    final pathMetrics = circlePath.computeMetrics();
    
    for (final metric in pathMetrics) {
      final circleLength = metric.length;
      final extractPath = metric.extractPath(
        0,
        circleLength * circleProgress,
      );
      canvas.drawPath(extractPath, paint);
    }
    
    // Draw checkmark second
    if (progress > 0.5) {
      final checkProgress = math.min(1.0, (progress - 0.5) * 2); // Second half of animation
      
      final checkPath = Path();
      
      // Starting point (bottom left of check)
      final startX = size.width * 0.3;
      final startY = size.height * 0.55;
      
      // Bottom point of check
      final midX = size.width * 0.45;
      final midY = size.height * 0.7;
      
      // End point (top right of check)
      final endX = size.width * 0.75;
      final endY = size.height * 0.35;
      
      // Calculate current end points based on progress
      final currentMidX = startX + (midX - startX) * math.min(1, checkProgress * 2);
      final currentMidY = startY + (midY - startY) * math.min(1, checkProgress * 2);
      
      final currentEndX = midX + (endX - midX) * math.max(0, (checkProgress - 0.5) * 2);
      final currentEndY = midY + (endY - midY) * math.max(0, (checkProgress - 0.5) * 2);
      
      checkPath.moveTo(startX, startY);
      
      if (checkProgress <= 0.5) {
        checkPath.lineTo(currentMidX, currentMidY);
      } else {
        checkPath.lineTo(midX, midY);
        checkPath.lineTo(currentEndX, currentEndY);
      }
      
      canvas.drawPath(checkPath, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CheckmarkPainter oldDelegate) => 
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
} 