import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../../shared/providers/providers.dart';
import 'login_screen.dart';
import 'success_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with TickerProviderStateMixin {
  // Main page animation
  late final AnimationController _mainController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Staggered animations
  late final AnimationController _staggerController;
  late final List<Animation<double>> _staggeredFades;
  late final List<Animation<Offset>> _staggeredSlides;

  // Background blobs animation
  late final AnimationController _blobController;
  late final Animation<double> _blobAnimation;

  // Shimmer animation
  late final AnimationController _shimmerController;

  // Button glow animation
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus nodes
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // State
  bool _isProcessing = false;
  bool _isPasswordVisible = false;
  bool _isUsernameFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

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

    // Staggered animations (9 elements)
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _staggeredFades = List.generate(9, (index) {
      final start = index * 0.07;
      final end = start + 0.35;
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

    _staggeredSlides = List.generate(9, (index) {
      final start = index * 0.07;
      final end = start + 0.35;
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
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

    // Background blobs animation
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _blobAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _blobController, curve: Curves.easeInOut),
    );

    // Shimmer animation
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

    // Start animations
    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _staggerController.forward();
    });
  }

  void _initFocusListeners() {
    _usernameFocusNode.addListener(() {
      setState(() => _isUsernameFocused = _usernameFocusNode.hasFocus);
    });
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _navigateHome() {
    if (!mounted) return;
    ref.read(tabIndexProvider.notifier).state = 0;
    context.go(AppRoutes.home);
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
          message: 'Account Created!',
          subtitle: 'Welcome to Quirzy',
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

  void _showError(String message) {
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

  Future<void> _signUp() async {
    if (_isProcessing) return;

    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (username.isEmpty) return _showError('Please enter a username');
    if (email.isEmpty) return _showError('Please enter your email');
    if (!emailRegex.hasMatch(email)) {
      return _showError('Please enter a valid email address');
    }
    if (password.isEmpty) return _showError('Please enter a password');
    if (password.length < 6) {
      return _showError('Password must be at least 6 characters');
    }

    setState(() => _isProcessing = true);

    try {
      await ref.read(authProvider.notifier).signUp(email, password, username);

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
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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

    // Theme Colors
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
                _AnimatedLogo(primaryColor: primaryGreen),
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
                      top: size.height * 0.5,
                      right: -150 + (sin(value * pi * 1.5) * 30),
                      child: _AnimatedBlob(
                        color: const Color(
                          0xFF8B5CF6,
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
                        SizedBox(height: size.height * 0.02),

                        // ============ HERO TEXT ============
                        _buildAnimatedElement(
                          index: 0,
                          child: _AnimatedHeroText(
                            shimmerController: _shimmerController,
                            textMain: textMain,
                            primaryColor: primaryGreen,
                            title: "Create Account",
                            subtitle: "& Start Learning ✨",
                          ),
                        ),

                        const SizedBox(height: 8),
                        _buildAnimatedElement(
                          index: 1,
                          child: Text(
                            "Join thousands of learners on Quirzy",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: textSub,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        // ============ ERROR MESSAGE ============
                        const _AnimatedErrorWidget(),

                        // ============ USERNAME FIELD ============
                        _buildAnimatedElement(
                          index: 2,
                          child: _AnimatedTextField(
                            controller: _usernameController,
                            focusNode: _usernameFocusNode,
                            label: 'Username',
                            hintText: 'Choose a username',
                            prefixIcon: Icons.person_outline_rounded,
                            isFocused: _isUsernameFocused,
                            isDark: isDark,
                            textSub: textSub,
                            primaryColor: primaryGreen,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ============ EMAIL FIELD ============
                        _buildAnimatedElement(
                          index: 3,
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
                            primaryColor: primaryGreen,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ============ PASSWORD FIELD ============
                        _buildAnimatedElement(
                          index: 4,
                          child: _AnimatedTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            label: 'Password',
                            hintText: 'Create a password (min. 6 chars)',
                            obscureText: !_isPasswordVisible,
                            prefixIcon: Icons.lock_outline_rounded,
                            isFocused: _isPasswordFocused,
                            isDark: isDark,
                            textSub: textSub,
                            primaryColor: primaryGreen,
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

                        const SizedBox(height: 16),

                        // ============ PASSWORD STRENGTH INDICATOR ============
                        _buildAnimatedElement(
                          index: 5,
                          child: _PasswordStrengthIndicator(
                            password: _passwordController.text,
                            primaryColor: primaryGreen,
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        // ============ CREATE ACCOUNT BUTTON ============
                        _buildAnimatedElement(
                          index: 6,
                          child: _GlowingButton(
                            onPressed: _signUp,
                            glowAnimation: _glowAnimation,
                            primaryColor: primaryGreen,
                            secondaryColor: secondaryBlue,
                            child: Consumer(
                              builder: (context, ref, _) {
                                // Only watch isLoading for better performance
                                final isLoading =
                                    ref.watch(
                                      authProvider.select((s) => s.isLoading),
                                    ) ||
                                    _isProcessing;
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
                                              Icons.person_add_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "Create Account",
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

                        const SizedBox(height: 24),

                        // ============ SIGN IN LINK ============
                        _buildAnimatedElement(
                          index: 7,
                          child: Center(
                            child: _AnimatedSignInLink(
                              textSub: textSub,
                              primaryColor: primaryGreen,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pushReplacement(
                                  context,
                                  _createRoute(const LoginScreen()),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ============ TERMS & CONDITIONS ============
                        _buildAnimatedElement(
                          index: 8,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                "By creating an account, you agree to our Terms of Service and Privacy Policy",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: textSub.withOpacity(0.7),
                                  height: 1.5,
                                ),
                              ),
                            ),
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
  final Color primaryColor;

  const _AnimatedLogo({required this.primaryColor});

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
                  colors: [widget.primaryColor, const Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.4),
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
  final Color primaryColor;
  final String title;
  final String subtitle;

  const _AnimatedHeroText({
    required this.shimmerController,
    required this.textMain,
    required this.primaryColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
                    primaryColor,
                    const Color(0xFF3B82F6),
                    const Color(0xFF8B5CF6),
                    primaryColor,
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
                subtitle,
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
  final Color primaryColor;

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
    required this.primaryColor,
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
            color: widget.isFocused ? widget.primaryColor : widget.textSub,
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
                    widget.primaryColor,
                    _borderAnimation.value,
                  )!,
                  width: 1 + (_borderAnimation.value * 0.5),
                ),
                boxShadow: widget.isFocused
                    ? [
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(
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
                  color: widget.isFocused
                      ? widget.primaryColor
                      : widget.textSub,
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

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final Color primaryColor;

  const _PasswordStrengthIndicator({
    required this.password,
    required this.primaryColor,
  });

  int _getStrength() {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
        return '';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Very Strong';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return primaryColor;
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getStrength();
    final strengthColor = _getStrengthColor(strength);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: password.isEmpty ? 0 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: index < strength
                        ? strengthColor
                        : strengthColor.withOpacity(0.2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _getStrengthText(strength),
              key: ValueKey(strength),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: strengthColor,
              ),
            ),
          ),
        ],
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
                    scale: 0.8 + (value * 0.2),
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
  final Color primaryColor;
  final Color secondaryColor;

  const _GlowingButton({
    required this.onPressed,
    required this.child,
    required this.glowAnimation,
    required this.primaryColor,
    required this.secondaryColor,
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
                  colors: [widget.primaryColor, widget.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(
                      widget.glowAnimation.value,
                    ),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: widget.secondaryColor.withOpacity(
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

class _AnimatedSignInLink extends StatefulWidget {
  final Color textSub;
  final Color primaryColor;
  final VoidCallback onTap;

  const _AnimatedSignInLink({
    required this.textSub,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_AnimatedSignInLink> createState() => _AnimatedSignInLinkState();
}

class _AnimatedSignInLinkState extends State<_AnimatedSignInLink>
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
              const TextSpan(text: "Already have an account? "),
              TextSpan(
                text: "Sign In",
                style: TextStyle(
                  color: widget.primaryColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: widget.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
