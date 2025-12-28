import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// --- YOUR IMPORTS ---
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/features/auth/presentation/screens/signup_screen.dart';
import 'package:quirzy/features/auth/presentation/screens/success_screen.dart';
import 'package:quirzy/features/home/screens/home_screen.dart';
import 'package:quirzy/core/services/notification_service.dart';
import 'package:quirzy/core/widgets/inputs/custom_text_field.dart'; // ✅ Using your custom widget

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage>
    with SingleTickerProviderStateMixin {
  // Animation
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Visibility State
  bool _isPasswordVisible = false;

  // Email regex
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
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
          message: 'Signed In!',
          subtitle: 'Welcome back to Quirzy',
        ),
      ),
    );
  }

  Future<void> _signIn() async {
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

    // --- EXACT COLORS FROM HOME SCREEN ---
    final primaryBlue = const Color(0xFF3B82F6);
    final bgLight = const Color(0xFFF0F4F8);
    final bgDark = Colors.black; // Pure Black
    
    final textMain = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? bgDark : bgLight,
        body: Stack(
          children: [
            // 1. Mesh Background Blobs
            Positioned(
              top: -100, right: -50,
              child: _buildBlurBlob(primaryBlue.withOpacity(isDark ? 0.12 : 0.15), 400),
            ),
            Positioned(
              bottom: -50, left: -100,
              child: _buildBlurBlob(isDark ? const Color(0xFF6366F1).withOpacity(0.12) : const Color(0xFF818CF8).withOpacity(0.15), 500),
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
                        
                        // --- Custom Back Button ---
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF18181b) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Icon(Icons.arrow_back_rounded, size: 20, color: textMain),
                          ),
                        ),

                        SizedBox(height: size.height * 0.05),

                        // --- Headings ---
                        Text(
                          "Welcome Back",
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
                          "Sign in to continue your progress",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: size.height * 0.06),

                        // --- Reusable Text Field (Email) ---
                        ReusableTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hintText: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: textSub,
                            size: 20,
                          ),
                          // Matches the glass theme border color
                          borderSideColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                        ),

                        const SizedBox(height: 20),

                        // --- Reusable Text Field (Password) ---
                        ReusableTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Enter your password',
                          obscureText: !_isPasswordVisible,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: textSub,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              color: textSub,
                              size: 20,
                            ),
                          ),
                          borderSideColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                        ),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.05),

                        // Error display
                        const _SignInErrorMessageWidget(),

                        // --- Sign In Button ---
                        _AnimatedButton(
                          onPressed: _signIn,
                          backgroundColor: primaryBlue,
                          shadowColor: primaryBlue.withOpacity(0.4),
                          child: Consumer(
                            builder: (context, ref, _) {
                              final isLoading = ref.watch(authProvider).isLoading;
                              return isLoading
                                  ? const SizedBox(
                                      height: 24, width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Text(
                                      "Sign In",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- Register Link ---
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                _createRoute(const SignUpPage()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textSub,
                                ),
                                children: [
                                  const TextSpan(text: "Don't have an account? "),
                                  TextSpan(
                                    text: "Register",
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

  // Helper for background blobs
  Widget _buildBlurBlob(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: const SizedBox(),
      ),
    );
  }
}

// ---------------------- ANIMATED BUTTON ----------------------

class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;

  const _AnimatedButton({
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
    this.borderColor,
    this.shadowColor,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
            border: widget.borderColor != null ? Border.all(color: widget.borderColor!) : null,
            boxShadow: widget.shadowColor != null
                ? [BoxShadow(color: widget.shadowColor!, blurRadius: 20, offset: const Offset(0, 10))]
                : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}

// ---------------------- ERROR WIDGET ----------------------

class _SignInErrorMessageWidget extends ConsumerWidget {
  const _SignInErrorMessageWidget();

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
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
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