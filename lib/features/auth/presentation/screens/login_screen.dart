import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/features/auth/presentation/screens/signup_screen.dart';
import 'package:quirzy/features/auth/presentation/screens/success_screen.dart';
import 'package:quirzy/features/home/screens/home_screen.dart';
import 'package:quirzy/core/services/notification_service.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage>
    with TickerProviderStateMixin {
  // Main Page Animation
  late final AnimationController _mainController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Staggered Animations
  late final AnimationController _staggerController;
  late final List<Animation<double>> _staggeredFades;
  late final List<Animation<Offset>> _staggeredSlides;

  // Floating Blobs Animation
  late final AnimationController _blobController;
  late final Animation<double> _blobAnimation;

  // Text Shimmer Animation
  late final AnimationController _shimmerController;

  // Button Glow Animation
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  // Field Focus Animation
  late final AnimationController _focusController;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus Nodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // State
  bool _isPasswordVisible = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  // Email regex
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initFocusListeners();
  }

  void _initAnimations() {
    // Main fade/slide animation
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Staggered animations for elements (7 elements total)
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _staggeredFades = List.generate(7, (index) {
      final start = index * 0.08;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _staggeredSlides = List.generate(7, (index) {
      final start = index * 0.08;
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // Floating blobs animation (continuous)
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _blobAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _blobController, curve: Curves.easeInOut),
    );

    // Shimmer animation for text
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Button glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Focus animation controller
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Start animations
    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _staggerController.forward();
    });
  }

  void _initFocusListeners() {
    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _staggerController.dispose();
    _blobController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    _focusController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateHome() {
    if (!mounted) return;
    ref.read(tabIndexProvider.notifier).state = 0;

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  void _showSuccessScreen() {
    if (!mounted) return;
    ref.read(tabIndexProvider.notifier).state = 0;
    HapticFeedback.mediumImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SuccessScreen(
          onComplete: _navigateHome,
          message: 'Signed In!',
          subtitle: 'Welcome back to Quirzy',
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _signIn() async {
    HapticFeedback.selectionClick();
    final authNotifier = ref.read(authProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) return _showError('Please enter your email');
    if (!_emailRegex.hasMatch(email)) {
      return _showError('Invalid email format');
    }
    if (password.isEmpty) {
      return _showError('Please enter your password');
    }
    if (password.length < 6) {
      return _showError('Password must be at least 6 characters');
    }

    try {
      await authNotifier.login(email, password);

      if (!mounted) return;

      if (ref.read(authProvider).value != null) {
        try {
          await ref.read(notificationProvider.notifier).sendTokenAfterLogin();
        } catch (e) {
          debugPrint('⚠️ Could not send FCM token: $e');
        }
        _showSuccessScreen();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final primaryGreen = const Color(0xFF5B13EC);
    final secondaryBlue = const Color(0xFF8B5CF6);
    final bgLight = const Color(0xFFF9F8FC);
    final bgDark = const Color(0xFF0F0F0F);

    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? bgDark : bgLight,
        // ============ MATERIAL APP BAR ============
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _AnimatedBackButton(
              onTap: () => Navigator.pop(context),
              isDark: isDark,
            ),
          ),
          title: FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AnimatedLogo(primaryBlue: primaryGreen),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primaryGreen, secondaryBlue],
                  ).createShader(bounds),
                  child: Text(
                    'Quirzy',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // ============ ANIMATED BACKGROUND BLOBS ============
            AnimatedBuilder(
              animation: _blobAnimation,
              builder: (context, child) {
                final value = _blobAnimation.value;
                return Stack(
                  children: [
                    Positioned(
                      top: -80 + (sin(value * pi * 2) * 20),
                      right: -30 + (cos(value * pi * 2) * 15),
                      child: _AnimatedBlob(
                        color: primaryGreen.withOpacity(isDark ? 0.15 : 0.12),
                        size: 350 + (sin(value * pi) * 30),
                        blurSigma: 90,
                      ),
                    ),
                    Positioned(
                      bottom: -100 + (cos(value * pi * 2) * 25),
                      left: -80 + (sin(value * pi * 2) * 20),
                      child: _AnimatedBlob(
                        color: secondaryBlue.withOpacity(isDark ? 0.12 : 0.10),
                        size: 400 + (cos(value * pi) * 35),
                        blurSigma: 100,
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.4,
                      right: -150 + (sin(value * pi * 1.5) * 30),
                      child: _AnimatedBlob(
                        color: const Color(
                          0xFF06B6D4,
                        ).withOpacity(isDark ? 0.08 : 0.06),
                        size: 300 + (sin(value * pi * 0.5) * 25),
                        blurSigma: 80,
                      ),
                    ),
                  ],
                );
              },
            ),

            // ============ FLOATING PARTICLES ============
            ...List.generate(6, (index) {
              return _FloatingParticle(
                index: index,
                controller: _blobController,
                isDark: isDark,
                primaryColor: primaryGreen,
              );
            }),

            // ============ MAIN CONTENT ============
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.03),

                        // ============ HERO TEXT WITH ANIMATIONS ============
                        _buildAnimatedElement(
                          index: 0,
                          child: _AnimatedHeroText(
                            shimmerController: _shimmerController,
                            textMain: textMain,
                            primaryBlue: primaryGreen,
                          ),
                        ),

                        const SizedBox(height: 8),
                        _buildAnimatedElement(
                          index: 1,
                          child: Text(
                            "Sign in to continue your learning journey",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: textSub,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.05),

                        // ============ ANIMATED EMAIL FIELD ============
                        _buildAnimatedElement(
                          index: 2,
                          child: _AnimatedTextField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            label: 'Email Address',
                            hintText: 'name@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline_rounded,
                            isFocused: _isEmailFocused,
                            isDark: isDark,
                            textSub: textSub,
                            primaryBlue: primaryGreen,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ============ ANIMATED PASSWORD FIELD ============
                        _buildAnimatedElement(
                          index: 3,
                          child: _AnimatedTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            label: 'Password',
                            hintText: 'Enter your password',
                            obscureText: !_isPasswordVisible,
                            prefixIcon: Icons.lock_outline_rounded,
                            isFocused: _isPasswordFocused,
                            isDark: isDark,
                            textSub: textSub,
                            primaryBlue: primaryGreen,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  key: ValueKey(_isPasswordVisible),
                                  color: textSub,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ============ FORGOT PASSWORD ============
                        _buildAnimatedElement(
                          index: 4,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: _AnimatedTextButton(
                                text: "Forgot Password?",
                                color: primaryGreen,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        // ============ ERROR DISPLAY ============
                        const _AnimatedErrorWidget(),

                        // ============ ANIMATED SIGN IN BUTTON ============
                        _buildAnimatedElement(
                          index: 5,
                          child: _GlowingButton(
                            onPressed: _signIn,
                            glowAnimation: _glowAnimation,
                            primaryBlue: primaryGreen,
                            secondaryPurple: secondaryBlue,
                            child: Consumer(
                              builder: (context, ref, _) {
                                final isLoading = ref
                                    .watch(authProvider)
                                    .isLoading;
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: isLoading
                                      ? const SizedBox(
                                          key: ValueKey('loading'),
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          key: const ValueKey('button'),
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.login_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "Sign In",
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ],
                                        ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ============ REGISTER LINK ============
                        _buildAnimatedElement(
                          index: 6,
                          child: Center(
                            child: _AnimatedRegisterLink(
                              textSub: textSub,
                              primaryBlue: primaryGreen,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pushReplacement(
                                  context,
                                  _createRoute(const SignUpPage()),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ============ SOCIAL LOGIN DIVIDER ============
                        _buildAnimatedElement(
                          index: 6,
                          child: _AnimatedDivider(textSub: textSub),
                        ),

                        const SizedBox(height: 24),

                        // ============ SOCIAL BUTTONS ============
                        _buildAnimatedElement(
                          index: 6,
                          child: Row(
                            children: [
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.g_mobiledata_rounded,
                                  label: 'Google',
                                  isDark: isDark,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.apple_rounded,
                                  label: 'Apple',
                                  isDark: isDark,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedElement({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _staggeredFades[index.clamp(0, _staggeredFades.length - 1)],
      child: SlideTransition(
        position: _staggeredSlides[index.clamp(0, _staggeredSlides.length - 1)],
        child: child,
      ),
    );
  }
}

// ==================== ANIMATED WIDGETS ====================

class _AnimatedBackButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _AnimatedBackButton({required this.onTap, required this.isDark});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
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
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  final Color primaryBlue;

  const _AnimatedLogo({required this.primaryBlue});

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [widget.primaryBlue, const Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryBlue.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double blurSigma;

  const _AnimatedBlob({
    required this.color,
    required this.size,
    required this.blurSigma,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: const SizedBox(),
      ),
    );
  }
}

class _FloatingParticle extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final bool isDark;
  final Color primaryColor;

  const _FloatingParticle({
    required this.index,
    required this.controller,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = Random(index);
    final startX = random.nextDouble() * size.width;
    final startY = random.nextDouble() * size.height;
    final particleSize = 4.0 + random.nextDouble() * 4;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = controller.value;
        final xOffset = sin((value + index * 0.2) * pi * 2) * 30;
        final yOffset = cos((value + index * 0.3) * pi * 2) * 20;
        final opacity = 0.3 + sin((value + index * 0.1) * pi) * 0.2;

        return Positioned(
          left: startX + xOffset,
          top: startY + yOffset,
          child: Container(
            width: particleSize,
            height: particleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(opacity.clamp(0.0, 1.0)),
              boxShadow: [
                BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedHeroText extends StatelessWidget {
  final AnimationController shimmerController;
  final Color textMain;
  final Color primaryBlue;

  const _AnimatedHeroText({
    required this.shimmerController,
    required this.textMain,
    required this.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: textMain,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: shimmerController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    primaryBlue,
                    const Color(0xFF8B5CF6),
                    const Color(0xFF06B6D4),
                    primaryBlue,
                  ],
                  stops: [
                    0.0,
                    shimmerController.value,
                    shimmerController.value + 0.2,
                    1.0,
                  ].map((e) => e.clamp(0.0, 1.0)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                "to Quirzy ✨",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool isFocused;
  final bool isDark;
  final Color textSub;
  final Color primaryBlue;

  const _AnimatedTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    required this.prefixIcon,
    this.suffixIcon,
    required this.isFocused,
    required this.isDark,
    required this.textSub,
    required this.primaryBlue,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _borderController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _borderController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocused != oldWidget.isFocused) {
      if (widget.isFocused) {
        _borderController.forward();
      } else {
        _borderController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: widget.isFocused ? widget.primaryBlue : widget.textSub,
          ),
          child: Text(widget.label),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color.lerp(
                    widget.isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                    widget.primaryBlue,
                    _borderAnimation.value,
                  )!,
                  width: 1 + (_borderAnimation.value * 0.5),
                ),
                boxShadow: widget.isFocused
                    ? [
                        BoxShadow(
                          color: widget.primaryBlue.withOpacity(
                            0.1 * _borderAnimation.value,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: widget.textSub.withOpacity(0.6),
              ),
              prefixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.prefixIcon,
                  key: ValueKey(widget.isFocused),
                  color: widget.isFocused ? widget.primaryBlue : widget.textSub,
                  size: 20,
                ),
              ),
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: widget.isDark ? const Color(0xFF151515) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedTextButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedTextButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedTextButton> createState() => _AnimatedTextButtonState();
}

class _AnimatedTextButtonState extends State<_AnimatedTextButton>
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
      end: 0.95,
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
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Text(
          widget.text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _AnimatedErrorWidget extends ConsumerWidget {
  const _AnimatedErrorWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch error for better performance
    final error = ref.watch(authProvider.select((s) => s.error?.toString()));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: (error != null && error.isNotEmpty)
          ? Padding(
              key: ValueKey(error),
              padding: const EdgeInsets.only(bottom: 20),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          error,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}

class _GlowingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Animation<double> glowAnimation;
  final Color primaryBlue;
  final Color secondaryPurple;

  const _GlowingButton({
    required this.onPressed,
    required this.child,
    required this.glowAnimation,
    required this.primaryBlue,
    required this.secondaryPurple,
  });

  @override
  State<_GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<_GlowingButton>
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
      end: 0.97,
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
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, widget.glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.primaryBlue, widget.secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryBlue.withOpacity(
                      widget.glowAnimation.value,
                    ),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: widget.secondaryPurple.withOpacity(
                      widget.glowAnimation.value * 0.5,
                    ),
                    blurRadius: 35,
                    offset: const Offset(0, 12),
                    spreadRadius: -4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedRegisterLink extends StatefulWidget {
  final Color textSub;
  final Color primaryBlue;
  final VoidCallback onTap;

  const _AnimatedRegisterLink({
    required this.textSub,
    required this.primaryBlue,
    required this.onTap,
  });

  @override
  State<_AnimatedRegisterLink> createState() => _AnimatedRegisterLinkState();
}

class _AnimatedRegisterLinkState extends State<_AnimatedRegisterLink>
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
      end: 0.97,
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
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.textSub,
            ),
            children: [
              const TextSpan(text: "Don't have an account? "),
              TextSpan(
                text: "Register",
                style: TextStyle(
                  color: widget.primaryBlue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: widget.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDivider extends StatelessWidget {
  final Color textSub;

  const _AnimatedDivider({required this.textSub});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, textSub.withOpacity(0.3)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textSub,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [textSub.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton>
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
      end: 0.95,
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
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 24,
                color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
