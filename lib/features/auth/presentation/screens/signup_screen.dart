import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// --- YOUR IMPORTS ---
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/features/auth/presentation/screens/login_screen.dart';
import 'package:quirzy/features/auth/presentation/screens/success_screen.dart';
import 'package:quirzy/features/home/screens/home_screen.dart';
import 'package:quirzy/core/services/notification_service.dart';
import 'package:quirzy/core/widgets/inputs/custom_text_field.dart'; // ✅ Using Custom Widget

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage>
    with SingleTickerProviderStateMixin {
  // Animation
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State
  bool _isProcessing = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Efficient Animation Setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Smooth 800ms
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateHome() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showSuccessScreen() {
    if (!mounted) return;
    ref.read(tabIndexProvider.notifier).state = 0;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          onComplete: _navigateHome,
          message: 'Account Created!',
          subtitle: 'Welcome to Quirzy',
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
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
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 220),
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

    // --- THEME COLORS ---
    final primaryBlue = const Color(0xFF3B82F6);
    final bgLight = const Color(0xFFF0F4F8);
    final bgDark = Colors.black; // PURE BLACK

    final textMain = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? bgDark : bgLight,
        body: Stack(
          children: [
            // 1. Mesh Background Blobs (Same as other screens)
            Positioned(
              top: -100,
              right: -50,
              child: _buildBlurBlob(
                primaryBlue.withOpacity(isDark ? 0.12 : 0.15),
                400,
              ),
            ),
            Positioned(
              bottom: -50,
              left: -100,
              child: _buildBlurBlob(
                isDark
                    ? const Color(0xFF6366F1).withOpacity(0.12)
                    : const Color(0xFF818CF8).withOpacity(0.15),
                500,
              ),
            ),

            // 2. Main Content
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
                        const SizedBox(height: 16),

                        // --- Back Button ---
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF18181b)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: textMain,
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        // --- Headings ---
                        Text(
                          "Create Account",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: textMain,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start your learning journey today",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: size.height * 0.05),

                        // --- Error Message ---
                        const _ErrorMessageWidget(),

                        // --- Input Fields using ReusableTextField ---
                        ReusableTextField(
                          controller: _usernameController,
                          label: "Username",
                          hintText: "Choose a username",
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: textSub,
                            size: 20,
                          ),
                          borderSideColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.2),
                        ),

                        const SizedBox(height: 16),

                        ReusableTextField(
                          controller: _emailController,
                          label: "Email",
                          hintText: "Enter your email",
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: textSub,
                            size: 20,
                          ),
                          borderSideColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.2),
                        ),

                        const SizedBox(height: 16),

                        ReusableTextField(
                          controller: _passwordController,
                          label: "Password",
                          hintText: "Create a password (min. 6 chars)",
                          obscureText: !_isPasswordVisible,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: textSub,
                            size: 20,
                          ),
                          borderSideColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.2),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: textSub,
                              size: 20,
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.05),

                        // --- Sign Up Button ---
                        _AnimatedButton(
                          onPressed: _signUp,
                          isProcessing: _isProcessing,
                          primaryColor: primaryBlue,
                        ),

                        SizedBox(height: size.height * 0.04),

                        // --- Footer ---
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                _createRoute(const SignInPage()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.transparent,
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textSub,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "Already have an account? ",
                                    ),
                                    TextSpan(
                                      text: 'Sign In',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
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

  // Background Blobs Helper
  Widget _buildBlurBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: const SizedBox(),
      ),
    );
  }
}

// ---------------- SUB WIDGETS ----------------

class _ErrorMessageWidget extends ConsumerWidget {
  const _ErrorMessageWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final error = authState.error?.toString();

    if (error != null && error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
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
      );
    }
    return const SizedBox.shrink();
  }
}

class _AnimatedButton extends ConsumerStatefulWidget {
  final VoidCallback onPressed;
  final bool isProcessing;
  final Color primaryColor;

  const _AnimatedButton({
    required this.onPressed,
    required this.isProcessing,
    required this.primaryColor,
  });

  @override
  ConsumerState<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends ConsumerState<_AnimatedButton>
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
    final isLoading = ref.watch(authProvider).isLoading || widget.isProcessing;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (!isLoading) widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  "Create Account",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
