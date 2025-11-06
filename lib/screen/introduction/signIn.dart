import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/screen/introduction/signup.dart';
import 'package:quirzy/screen/mainPage/mainScreen.dart';
import 'package:quirzy/widgets/textfiled.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  void _handleAuthStateChange(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (authState.isLoggedIn && context.mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (_, __) => _handleAuthStateChange(context, ref));
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: size.height - (MediaQuery.of(context).padding.top + kToolbarHeight),
          ),
          child: const _SignInForm(),
        ),
      ),
    );
  }
}

class _SignInForm extends ConsumerWidget {
  const _SignInForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.08,
        vertical: size.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          ReusableTextField(
            label: 'Email',
            hintText: 'Enter your email',
            onChanged: authNotifier.updateEmail,
          ),
          SizedBox(height: size.height * 0.025),
          ReusableTextField(
            label: 'Password',
            hintText: 'Enter your password',
            obscureText: true,
            onChanged: authNotifier.updatePassword,
          ),
          Consumer(
            builder: (context, ref, child) {
              final error = ref.watch(
                authProvider.select((state) => state.error),
              );
              return error != null
                  ? Padding(
                      padding: EdgeInsets.only(top: size.height * 0.015),
                      child: Text(
                        error,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          SizedBox(height: size.height * 0.04),
          Consumer(
            builder: (context, ref, child) {
              final isLoading = ref.watch(
                authProvider.select((state) => state.isLoading),
              );
              return SizedBox(
                width: double.infinity,
                height: size.height * 0.065,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _signIn(authNotifier, context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.08),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: colorScheme.onPrimary)
                      : Text(
                          "Sign In",
                          style: TextStyle(fontSize: size.width * 0.045),
                        ),
                ),
              );
            },
          ),
          SizedBox(height: size.height * 0.03),
          
          // OR Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Text(
                  "OR",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: size.width * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  thickness: 1,
                ),
              ),
            ],
          ),
          
          SizedBox(height: size.height * 0.03),
          
          // Google Sign-In Button
          SizedBox(
            width: double.infinity,
            height: size.height * 0.065,
            child: OutlinedButton.icon(
              onPressed: authState.isGoogleSigningIn || authState.isLoading
                  ? null
                  : () => _handleGoogleSignIn(ref, context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.08),
                ),
                side: BorderSide(
                  color: colorScheme.outline,
                  width: 1.5,
                ),
              ),
              icon: authState.isGoogleSigningIn
                  ? SizedBox(
                      width: size.width * 0.05,
                      height: size.width * 0.05,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Image.asset(
                      'assets/icon/google_icon.png',
                      height: size.width * 0.06,
                      width: size.width * 0.06,
                    ),
              label: Text(
                authState.isGoogleSigningIn
                    ? "Signing in..."
                    : "Continue with Google",
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          
          SizedBox(height: size.height * 0.03),
          
          Center(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              ),
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: size.width * 0.038,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.05),
        ],
      ),
    );
  }

  // Email/Password Sign In
  Future<void> _signIn(AuthNotifier authNotifier, BuildContext context) async {
    final email = authNotifier.state.email;
    final password = authNotifier.state.password;

    if (email == null || email.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email')),
        );
      }
      return;
    }

    if (password == null || password.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your password')),
        );
      }
      return;
    }

    try {
      await authNotifier.login(email, password);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
            ),
          ),
        );
      }
    }
  }

  // Google Sign-In Handler
  Future<void> _handleGoogleSignIn(WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(authProvider.notifier).initializeAndAuthenticateGoogle();
      
      // Navigation is handled by authProvider listener in parent widget
      // No need to manually navigate here
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google sign-in failed: ${e.toString()}',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
