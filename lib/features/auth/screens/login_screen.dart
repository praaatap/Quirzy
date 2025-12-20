import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/features/auth/screens/signup_screen.dart';
import 'package:quirzy/features/auth/screens/success_screen.dart';
import 'package:quirzy/features/home/screens/main_screen.dart';
import 'package:quirzy/service/notification_service.dart';
import 'package:quirzy/shared/widgets/inputs/custom_text_field.dart';

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
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
      MaterialPageRoute(builder: (_) => const MainScreen()),
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
      return _showError('Invalid email format (e.g., name@gmail.com)');
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

      if (ref.read(authProvider).isLoggedIn) {
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface,
              size: 18,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Circles (solid dark teal)
          RepaintBoundary(
            child: Stack(
              children: [
                // Top-right circle
                Positioned(
                  top: -100,
                  right: -80,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF12292F),
                    ),
                  ),
                ),
                // Bottom-left circle
                Positioned(
                  bottom: 80,
                  left: -100,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0F2328),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.04),
                      Text(
                        "Welcome Back",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onBackground,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign in to continue your journey",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),

                      ReusableTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      ReusableTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter your password',
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      const _SignInErrorMessageWidget(),

                      _SignInButtonWidget(signInCallback: _signIn),

                      SizedBox(height: size.height * 0.04),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              _createRoute(const SignUpPage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            color: Colors.transparent,
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------- EXTRACTED WIDGETS ----------------------

class _SignInErrorMessageWidget extends ConsumerWidget {
  const _SignInErrorMessageWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(authProvider.select((s) => s.error));
    final theme = Theme.of(context);

    if (error != null && error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onErrorContainer,
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

class _SignInButtonWidget extends ConsumerWidget {
  final VoidCallback signInCallback;

  const _SignInButtonWidget({required this.signInCallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final theme = Theme.of(context);
    final enabled = !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: enabled ? signInCallback : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                "Sign In",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
