import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/screen/introduction/signIn.dart';
import 'package:quirzy/screen/introduction/success_screen.dart';
import 'package:quirzy/screen/mainPage/mainScreen.dart';
import 'package:quirzy/service/notification_service.dart';
import 'package:quirzy/widgets/textfiled.dart';

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
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
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

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
      final notifier = ref.read(authProvider.notifier);
      notifier.updateUsername(username);
      notifier.updateEmail(email);
      notifier.updatePassword(password);

      await notifier.signUp();

      if (!mounted) return;

      if (ref.read(authProvider).isLoggedIn) {
        try {
          await ref
              .read(notificationProvider.notifier)
              .sendTokenAfterLogin();
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
      reverseTransitionDuration:
          const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) =>
          page,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
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
      resizeToAvoidBottomInset: true,
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
          // Lightweight Background Gradient
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.07,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Text(
                        "Create Account",
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
                        "Start your learning journey",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),

                      const _ErrorMessageWidget(),

                      ReusableTextField(
                        controller: _usernameController,
                        label: "Username",
                        hintText: "Choose username",
                      ),
                      const SizedBox(height: 20),
                      ReusableTextField(
                        controller: _emailController,
                        label: "Email",
                        hintText: "Enter your email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      ReusableTextField(
                        controller: _passwordController,
                        label: "Password",
                        hintText: "Create password (min. 6 chars)",
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible =
                                  !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: theme
                                .colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      _SignUpButtonWidget(
                        signUpCallback: _signUp,
                        isProcessing: _isProcessing,
                      ),

                      SizedBox(height: size.height * 0.04),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              _createRoute(const SignInPage()),
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
                                text: "Already have an account? ",
                                style:
                                    GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: theme
                                      .colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme
                                          .colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),
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

// ---------------- SUB WIDGETS ----------------

class _ErrorMessageWidget extends ConsumerWidget {
  const _ErrorMessageWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error =
        ref.watch(authProvider.select((s) => s.error));
    final theme = Theme.of(context);

    if (error != null && error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.error.withOpacity(0.2),
            ),
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
                    color: theme
                        .colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
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

class _SignUpButtonWidget extends ConsumerWidget {
  final VoidCallback signUpCallback;
  final bool isProcessing;

  const _SignUpButtonWidget({
    required this.signUpCallback,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthLoading =
        ref.watch(authProvider.select((s) => s.isLoading));
    final theme = Theme.of(context);
    final isLoading = isAuthLoading || isProcessing;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : signUpCallback,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          disabledBackgroundColor:
              theme.colorScheme.primary.withOpacity(0.7),
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
                "Create Account",
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
