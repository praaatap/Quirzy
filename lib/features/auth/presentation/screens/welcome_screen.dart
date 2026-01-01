import 'dart:math';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:go_router/go_router.dart';

// --- YOUR IMPORTS ---
import 'package:quirzy/routes/app_routes.dart';
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/features/auth/presentation/screens/success_screen.dart';
import 'package:quirzy/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:quirzy/core/services/notification_service.dart';

class QuiryHome extends ConsumerStatefulWidget {
  const QuiryHome({super.key});

  @override
  ConsumerState<QuiryHome> createState() => _QuiryHomeState();
}

class _QuiryHomeState extends ConsumerState<QuiryHome>
    with TickerProviderStateMixin {
  // Animation Controllers
  late final AnimationController _entranceController;
  late final AnimationController _backgroundController;
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  // Staggered Animations
  late final Animation<double> _fadeHero;
  late final Animation<Offset> _slideHero;
  late final Animation<double> _fadeText;
  late final Animation<Offset> _slideText;
  late final Animation<double> _fadeButtons;
  late final Animation<Offset> _slideButtons;

  // Local State
  bool _isPrivacyPolicyAccepted = false;
  bool _isGoogleLoading = false;
  bool _hasShowcaseBeenShown = false;

  // Keys
  final GlobalKey _checkboxKey = GlobalKey();

  // Colors
  static const primaryColor = Color(0xFF5B13EC);
  static const primaryLight = Color(0xFFEFE9FD);

  @override
  void initState() {
    super.initState();

    // 1. Entrance Controller (Staggered)
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeHero = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideHero = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _fadeText = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );
    _slideText = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _fadeButtons = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _slideButtons = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _entranceController.forward();

    // 2. Background Animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // 3. Floating Animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
    // Showcase is now triggered in build method with correct context
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _backgroundController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  void _showConsentRequiredMessage() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Please accept the Privacy Policy to continue',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _triggerShowcase(BuildContext showcaseContext) {
    if (mounted) {
      ShowCaseWidget.of(showcaseContext).startShowCase([_checkboxKey]);
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext showcaseContext) async {
    if (!_isPrivacyPolicyAccepted) {
      _showConsentRequiredMessage();
      // Highlight the checkbox again if they missed it
      _triggerShowcase(showcaseContext);
      return;
    }
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await ref.read(authProvider.notifier).googleSignIn();
      if (!mounted) return;

      if (ref.read(authProvider).value != null) {
        // Try getting FCM token
        try {
          await ref.read(notificationProvider.notifier).sendTokenAfterLogin();
        } catch (e) {
          debugPrint('⚠️ Could not send FCM token: $e');
        }
        if (!mounted) return;

        ref.read(tabIndexProvider.notifier).state = 0;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              onComplete: () {
                context.go(AppRoutes.home);
              },
              message: 'Signed In!',
              subtitle: 'Welcome back to Quirzy',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final isAuthLoading = ref.watch(authProvider).isLoading;
    final isProcessing = isAuthLoading || _isGoogleLoading;

    return ShowCaseWidget(
      builder: (showcaseContext) {
        // Trigger showcase on first build if policy not accepted
        if (!_hasShowcaseBeenShown && !_isPrivacyPolicyAccepted) {
          _hasShowcaseBeenShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _triggerShowcase(showcaseContext);
            }
          });
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
          body: Stack(
            children: [
              // 1. Animated Radial Background
              AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _BackgroundPainter(
                      animationValue: _backgroundController.value,
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    size: Size.infinite,
                  );
                },
              ),

              // 2. Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // --- HERO SECTION ---
                      FadeTransition(
                        opacity: _fadeHero,
                        child: SlideTransition(
                          position: _slideHero,
                          child: _buildHeroSection(size, isDark),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // --- TEXT SECTION ---
                      FadeTransition(
                        opacity: _fadeText,
                        child: SlideTransition(
                          position: _slideText,
                          child: Column(
                            children: [
                              Text(
                                "Unlock your potential\nwith Quirzy",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Master any subject with smart, AI-generated quizzes tailored just for you.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // --- BOTTOM SECTION ---
                      FadeTransition(
                        opacity: _fadeButtons,
                        child: SlideTransition(
                          position: _slideButtons,
                          child: Column(
                            children: [
                              _buildPrivacyCheckbox(isDark),
                              const SizedBox(height: 24),

                              // Google Button
                              _AnimatedButton(
                                onPressed: isProcessing
                                    ? null
                                    : () =>
                                          _handleGoogleSignIn(showcaseContext),
                                backgroundColor: isDark
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                borderColor: isDark
                                    ? const Color(0xFF262626)
                                    : const Color(0xFFE2E8F0),
                                child: isProcessing
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primaryColor,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/icon/google_icon.png',
                                            height: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "Continue with Google",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(Size size, bool isDark) {
    return SizedBox(
      height: size.height * 0.35,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: size.width * 0.7,
            height: size.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [primaryColor.withOpacity(0.4), Colors.transparent],
                stops: const [0.0, 0.7],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),

          // Main Image Container
          Transform.rotate(
            angle: -0.05,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8, // Square aspect ratio
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(isDark ? 0.1 : 0.8),
                  width: 4,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/welcome.png', fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            (isDark ? const Color(0xFF0F0A18) : Colors.white)
                                .withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Badge
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 40 + _floatAnimation.value,
                right: 30,
                child: Transform.rotate(angle: 0.1, child: child!),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262626) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Gen",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        "Latest Tech",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCheckbox(bool isDark) {
    return Showcase(
      key: _checkboxKey,
      title: 'Required',
      description: 'Please accept the Privacy Policy to continue',
      targetBorderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _isPrivacyPolicyAccepted = !_isPrivacyPolicyAccepted);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPrivacyPolicyAccepted
                  ? primaryColor
                  : (isDark
                        ? const Color(0xFF262626)
                        : const Color(0xFFE2E8F0)),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _isPrivacyPolicyAccepted
                      ? primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isPrivacyPolicyAccepted
                        ? primaryColor
                        : (isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1)),
                    width: 2,
                  ),
                ),
                child: _isPrivacyPolicyAccepted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(
                    context,
                  ).push(_createRoute(const PrivacyPolicyScreen())),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: "I agree to the "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        const TextSpan(text: " & "),
                        TextSpan(
                          text: "Terms",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color? borderColor;

  const _AnimatedButton({
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
    this.borderColor,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  final Color primaryColor;

  _BackgroundPainter({
    required this.animationValue,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Base Blob 1
    final colors1 = [
      primaryColor.withOpacity(isDark ? 0.15 : 0.08),
      Colors.transparent,
    ];
    // Move slightly with animation
    final offset1 = Offset(
      size.width * 0.8 + (sin(animationValue * 2 * pi) * 20),
      size.height * 0.1 + (cos(animationValue * 2 * pi) * 20),
    );
    paint.shader = RadialGradient(
      colors: colors1,
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: offset1, radius: 250));
    canvas.drawCircle(offset1, 250, paint);

    // Base Blob 2
    final colors2 = [
      (isDark ? const Color(0xFF9333EA) : const Color(0xFFC084FC)).withOpacity(
        isDark ? 0.15 : 0.08,
      ),
      Colors.transparent,
    ];
    final offset2 = Offset(
      size.width * 0.1 + (cos(animationValue * 2 * pi) * 20),
      size.height * 0.9 + (sin(animationValue * 2 * pi) * 20),
    );
    paint.shader = RadialGradient(
      colors: colors2,
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: offset2, radius: 300));
    canvas.drawCircle(offset2, 300, paint);
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}
