import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/screen/mainPage/mainScreen.dart';
import 'package:quirzy/widgets/textfiled.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      await ref.read(authProvider.notifier).pickAndUploadImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _navigateHome() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false, // This predicate removes all routes
      );
    }
  }

  Future<void> _signUp() async {
    final notifier = ref.read(authProvider.notifier);

    try {
      await notifier.signUp();
      if (ref.read(authProvider).isLoggedIn) {
        _navigateHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await ref.read(authProvider.notifier).initializeAndAuthenticateGoogle();

      if (ref.read(authProvider).isLoggedIn) {
        _navigateHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    final isOverallLoading = authState.isLoading || authState.isGoogleSigningIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  authState.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.surfaceVariant,
                foregroundImage: authState.profileImage != null
                    ? FileImage(File(authState.profileImage!.path))
                    : null,
                child: authState.isUploadingImage
                    ? CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      )
                    : authState.profileImage == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
              ),
            ),
            const SizedBox(height: 32),
            ReusableTextField(
              controller: _usernameController,
              label: "Username",
              hintText: "Enter your username",
              onChanged: (value) =>
                  ref.read(authProvider.notifier).updateUsername(value),
            ),
            const SizedBox(height: 16),
            ReusableTextField(
              controller: _emailController,
              label: "Email",
              hintText: "Enter your email",
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) =>
                  ref.read(authProvider.notifier).updateEmail(value),
            ),
            const SizedBox(height: 16),
            ReusableTextField(
              controller: _passwordController,
              label: "Password",
              hintText: "Enter your password",
              obscureText: true,
              onChanged: (value) =>
                  ref.read(authProvider.notifier).updatePassword(value),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isOverallLoading ? null : _signUp,
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Sign Up"),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text("OR", style: theme.textTheme.labelSmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isOverallLoading ? null : _handleGoogleSignIn,
                icon: Image.asset(
                  'assets/icon/google_icon.png',
                  height: 24,
                  width: 24,
                ),
                label: Text(
                  authState.isGoogleSigningIn
                      ? "Signing In..."
                      : "Continue with Google",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}