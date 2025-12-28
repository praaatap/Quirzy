import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

// --- YOUR IMPORTS ---
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/features/auth/presentation/screens/login_screen.dart';
import 'package:quirzy/features/auth/presentation/screens/signup_screen.dart';
import 'package:quirzy/features/auth/presentation/screens/success_screen.dart';
import 'package:quirzy/features/home/screens/home_screen.dart';
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
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  // Local State
  bool _isPrivacyPolicyAccepted = false;
  bool _isGoogleLoading = false;

  // Keys
  final GlobalKey _checkboxKey = GlobalKey();
  final GlobalKey _googleLoginKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    // 1. Entrance Fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );
    _fadeController.forward();

    // 2. Floating Animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 3. Showcase Trigger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isPrivacyPolicyAccepted) {
        ShowCaseWidget.of(context).startShowCase([_checkboxKey]);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  void _showConsentRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Please accept the Privacy Policy to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (!_isPrivacyPolicyAccepted) {
      _showConsentRequiredMessage();
      return;
    }
    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      await ref.read(authProvider.notifier).googleSignIn();
      if (!mounted) return;

      if (ref.read(authProvider).value != null) {
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-in failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _onEmailLoginPressed() {
    if (!_isPrivacyPolicyAccepted) {
      _showConsentRequiredMessage();
      return;
    }
    Navigator.of(context).push(_createRoute(const SignInPage()));
  }

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
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // --- LOADING STATE ---
    final isAuthLoading = ref.watch(authProvider).isLoading;
    final isProcessing = isAuthLoading || _isGoogleLoading; 

    return Scaffold(
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND BLOBS
          Positioned(
            top: -100, right: -50,
            child: _buildBlurBlob(
              theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.1), 
              400
            ),
          ),
          Positioned(
            bottom: -50, left: -100,
            child: _buildBlurBlob(
              theme.colorScheme.secondary.withOpacity(isDark ? 0.15 : 0.1), 
              500
            ),
          ),

          // 2. MAIN CONTENT
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(flex: 1),
                    
                    // --- HERO IMAGE ---
                    _buildHeroSection(size, isDark, theme),

                    const Spacer(flex: 1),

                    // --- HEADINGS ---
                    Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: theme.textTheme.displayLarge, // Uses global theme
                            children: [
                              const TextSpan(text: "Unlock your potential with "),
                              TextSpan(
                                text: "Quizry", 
                                style: TextStyle(color: theme.colorScheme.primary)
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Master any subject with smart, AI-generated quizzes tailored just for you.",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // --- PRIVACY CHECKBOX ---
                    _buildPrivacyCheckbox(isDark, theme),

                    const SizedBox(height: 24),

                    // --- BUTTONS ---
                    Column(
                      children: [
                        // Google Button
                        Showcase(
                          key: _googleLoginKey,
                          title: 'Login',
                          description: 'Continue with Google',
                          child: _AnimatedButton(
                            onPressed: isProcessing ? null : _handleGoogleSignIn,
                            backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
                            borderColor: theme.colorScheme.outline,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isProcessing)
                                  SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)
                                  )
                                else ...[
                                  Image.asset('assets/icon/google_icon.png', height: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Continue with Google",
                                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // Email Button
                        _AnimatedButton(
                          onPressed: _onEmailLoginPressed,
                          backgroundColor: theme.colorScheme.primary,
                          borderColor: Colors.transparent,
                          // Uses theme shadow color logic
                          shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                "Sign in with Email",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // --- FOOTER ---
                    GestureDetector(
                      onTap: _onRegisterPressed,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: "Register",
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: theme.colorScheme.primary,
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
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

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

  Widget _buildHeroSection(Size size, bool isDark, ThemeData theme) {
    return SizedBox(
      height: size.height * 0.32, 
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.15 : 0.4), 
                width: 3
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.white.withOpacity(0.05) : theme.shadowColor.withOpacity(0.1),
                  blurRadius: 30, offset: const Offset(0, 25),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(33),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/welcome.png', fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter, end: Alignment.topCenter,
                        colors: [
                            // Adaptive gradient overlay
                            theme.scaffoldBackgroundColor.withOpacity(isDark ? 0.7 : 0.4), 
                            Colors.transparent
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) => Positioned(
              bottom: 24 + _floatAnimation.value.abs(),
              left: 20, right: 20,
              child: child!,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color?.withOpacity(0.85),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272a) : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.smart_toy_rounded, color: theme.colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "AI-GEN QUIZZES",
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900, 
                              letterSpacing: 0.5,
                              color: theme.colorScheme.onSurface
                            ),
                          ),
                          Text(
                            "Personalized Learning",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildPrivacyCheckbox(bool isDark, ThemeData theme) {
    return Showcase(
      key: _checkboxKey,
      title: 'Accept Policy',
      description: 'Required to continue',
      child: GestureDetector(
        onTap: () => setState(() => _isPrivacyPolicyAccepted = !_isPrivacyPolicyAccepted),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color?.withOpacity(isDark ? 0.8 : 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPrivacyPolicyAccepted 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 24, width: 24,
                child: Checkbox(
                  value: _isPrivacyPolicyAccepted,
                  onChanged: (v) => setState(() => _isPrivacyPolicyAccepted = v!),
                  activeColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(color: theme.colorScheme.outline, width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(_createRoute(const PrivacyPolicyScreen())),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.4),
                      children: [
                        const TextSpan(text: "I agree to the "),
                        TextSpan(
                          text: "Privacy Policy", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
                        ),
                        const TextSpan(text: " & "),
                        TextSpan(
                          text: "Terms", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
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

// --- ANIMATED BUTTON COMPONENT ---

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