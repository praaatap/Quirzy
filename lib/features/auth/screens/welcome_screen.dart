import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/features/auth/screens/login_screen.dart';
import 'package:quirzy/features/auth/screens/signup_screen.dart';
import 'package:quirzy/features/auth/screens/success_screen.dart';
import 'package:quirzy/features/home/screens/main_screen.dart';
import 'package:quirzy/features/settings/screens/privacy_policy_screen.dart';
import 'package:quirzy/service/notification_service.dart';

class QuiryHome extends ConsumerStatefulWidget {
  const QuiryHome({super.key});

  @override
  ConsumerState<QuiryHome> createState() => _QuiryHomeState();
}

class _QuiryHomeState extends ConsumerState<QuiryHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  // Checkbox State
  bool _isPrivacyPolicyAccepted = false;

  // Local loading state for Google button
  bool _isGoogleLoading = false;

  final GlobalKey _checkboxKey = GlobalKey();
  final GlobalKey _googleLoginKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isPrivacyPolicyAccepted) {
        ShowCaseWidget.of(context).startShowCase([_checkboxKey]);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showConsentRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Please accept the Privacy Policy to continue',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    // STRICT CHECK
    if (!_isPrivacyPolicyAccepted) {
      _showConsentRequiredMessage();
      return;
    }

    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      await ref.read(authProvider.notifier).initializeAndAuthenticateGoogle();

      if (!mounted) return;

      if (ref.read(authProvider).isLoggedIn) {
        try {
          await ref.read(notificationProvider.notifier).sendTokenAfterLogin();
        } catch (e) {
          debugPrint('⚠️ Could not send FCM token: $e');
        }

        // Navigate to Success Screen
        ref.read(tabIndexProvider.notifier).state = 0;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              onComplete: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                );
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
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _onEmailLoginPressed() {
    if (!_isPrivacyPolicyAccepted) {
      _showConsentRequiredMessage();
      return;
    }
    Navigator.of(context).push(_createRoute(const SignInPage()));
  }

  // Register Logic (Strictly checks Policy)
  void _onRegisterPressed() {
    if (!_isPrivacyPolicyAccepted) {
      _showConsentRequiredMessage();
      return;
    }
    Navigator.of(context).push(_createRoute(const SignUpPage()));
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final offsetAnim = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        final scaleAnim = Tween<double>(
          begin: 0.995,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: offsetAnim,
            child: ScaleTransition(scale: scaleAnim, child: child),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Only listen to isLoading, not whole auth state
    final isAuthLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final isProcessing = isAuthLoading || _isGoogleLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Circles (theme-adaptive)
          RepaintBoundary(
            child: Builder(
              builder: (context) {
                final isDark = theme.brightness == Brightness.dark;
                return Stack(
                  children: [
                    // Top-right circle
                    Positioned(
                      top: -100,
                      right: -80,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF12292F)
                              : theme.colorScheme.primary.withOpacity(0.08),
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF0F2328)
                              : theme.colorScheme.secondary.withOpacity(0.06),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: _Body(
                  size: size,
                  theme: theme,
                  isProcessing: isProcessing,
                  isPrivacyAccepted: _isPrivacyPolicyAccepted,
                  onPrivacyChanged: (value) {
                    setState(() {
                      _isPrivacyPolicyAccepted = value;
                    });
                  },
                  onGoogleSignIn: _handleGoogleSignIn,
                  onEmailLogin: _onEmailLoginPressed,
                  onRegister: _onRegisterPressed,
                  onConsentRequired: _showConsentRequiredMessage,
                  onPrivacyPolicyTap: () {
                    Navigator.of(
                      context,
                    ).push(_createRoute(const PrivacyPolicyScreen()));
                  },
                  checkboxKey: _checkboxKey,
                  googleLoginKey: _googleLoginKey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Size size;
  final ThemeData theme;
  final bool isProcessing;
  final bool isPrivacyAccepted;
  final void Function(bool) onPrivacyChanged;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onEmailLogin;
  final VoidCallback onRegister;
  final VoidCallback onConsentRequired;
  final VoidCallback onPrivacyPolicyTap;
  final GlobalKey checkboxKey;
  final GlobalKey googleLoginKey;

  const _Body({
    required this.size,
    required this.theme,
    required this.isProcessing,
    required this.isPrivacyAccepted,
    required this.onPrivacyChanged,
    required this.onGoogleSignIn,
    required this.onEmailLogin,
    required this.onRegister,
    required this.onConsentRequired,
    required this.onPrivacyPolicyTap,
    required this.checkboxKey,
    required this.googleLoginKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),

        // Logo
        RepaintBoundary(
          child: Hero(
            tag: 'welcome_logo',
            child: Container(
              height: size.height * 0.28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/welcome.png',
                  fit: BoxFit.cover,
                  cacheWidth:
                      (size.width *
                              0.84 *
                              MediaQuery.of(context).devicePixelRatio)
                          .round(),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: size.height * 0.05),

        Text(
          "Welcome to Quirzy",
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: size.height * 0.015),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Text(
            "Challenge yourself with AI-generated quizzes and track your progress",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),

        const Spacer(flex: 2),

        _PrivacyCheckbox(
          theme: theme,
          isAccepted: isPrivacyAccepted,
          onChanged: onPrivacyChanged,
          onPrivacyPolicyTap: onPrivacyPolicyTap,
          checkboxKey: checkboxKey,
        ),

        SizedBox(height: size.height * 0.025),

        _AuthButtons(
          theme: theme,
          isProcessing: isProcessing,
          isPrivacyAccepted: isPrivacyAccepted,
          onGoogleSignIn: onGoogleSignIn,
          onEmailLogin: onEmailLogin,
          onRegister: onRegister,
          onConsentRequired: onConsentRequired,
          googleLoginKey: googleLoginKey,
        ),

        const Spacer(flex: 3),
      ],
    );
  }
}

class _PrivacyCheckbox extends StatelessWidget {
  final ThemeData theme;
  final bool isAccepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onPrivacyPolicyTap;
  final GlobalKey checkboxKey;

  const _PrivacyCheckbox({
    required this.theme,
    required this.isAccepted,
    required this.onChanged,
    required this.onPrivacyPolicyTap,
    required this.checkboxKey,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: checkboxKey,
      title: 'Accept Privacy Policy',
      description: 'You must check this box to agree to our Privacy Policy.',
      targetShapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAccepted
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.errorContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAccepted
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.error.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: isAccepted,
                onChanged: (value) => onChanged(value ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GestureDetector(
                  onTap: onPrivacyPolicyTap,
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'I have read and agree to the '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' and Terms of Service'),
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
}

class _AuthButtons extends StatelessWidget {
  final ThemeData theme;
  final bool isProcessing;
  final bool isPrivacyAccepted;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onEmailLogin;
  final VoidCallback onRegister;
  final VoidCallback onConsentRequired;
  final GlobalKey googleLoginKey;

  const _AuthButtons({
    required this.theme,
    required this.isProcessing,
    required this.isPrivacyAccepted,
    required this.onGoogleSignIn,
    required this.onEmailLogin,
    required this.onRegister,
    required this.onConsentRequired,
    required this.googleLoginKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // GOOGLE BUTTON
        Showcase(
          key: googleLoginKey,
          title: 'Quick Login',
          description: 'Tap here to sign in quickly with Google.',
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : (isPrivacyAccepted ? onGoogleSignIn : onConsentRequired),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrivacyAccepted
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
                foregroundColor: isPrivacyAccepted
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.4),
                elevation: 0,
                side: BorderSide(
                  color: isPrivacyAccepted
                      ? theme.colorScheme.outline.withOpacity(0.5)
                      : Colors.transparent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isProcessing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else
                    Opacity(
                      opacity: isPrivacyAccepted ? 1.0 : 0.5,
                      child: Image.asset(
                        'assets/icon/google_icon.png',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Text(
                    isProcessing ? 'Signing in...' : 'Continue with Google',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // EMAIL BUTTON
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isPrivacyAccepted ? onEmailLogin : onConsentRequired,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrivacyAccepted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              foregroundColor: isPrivacyAccepted
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              elevation: isPrivacyAccepted ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Sign in with Email',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // REGISTER LINK
        GestureDetector(
          onTap: isPrivacyAccepted ? onRegister : onConsentRequired,
          child: Text.rich(
            TextSpan(
              text: "Don't have an account? ",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: 'Register',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: isPrivacyAccepted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
