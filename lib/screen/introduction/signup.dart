import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/screen/introduction/signIn.dart';
import 'package:quirzy/screen/mainPage/mainScreen.dart';
import 'package:quirzy/widgets/textfiled.dart'; // Assuming this is your custom text field widget

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

  // Function to handle image picking and upload
  Future<void> _pickImage() async {
    try {
      await ref.read(authProvider.notifier).pickAndUploadImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // Function to handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      await ref.read(authProvider.notifier).signInwithGoogle();
      if (mounted && ref.read(authProvider).user != null) {
        // Navigate to the main screen upon successful sign-in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // Function to handle email/password sign-up
  Future<void> _signUp() async {
    final authNotifier = ref.read(authProvider.notifier);
    authNotifier
      ..updateUsername(_usernameController.text.trim())
      ..updateEmail(_emailController.text.trim())
      ..updatePassword(_passwordController.text.trim());
    try {
      await authNotifier.signUp();
      if (mounted && ref.read(authProvider).user != null) {
        // Navigate to the main screen upon successful sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the authProvider to react to state changes (e.g., loading, error, profile image)
    final authState = ref.watch(authProvider);
    // Access the current theme's color scheme for dynamic styling
    final colorScheme = Theme.of(context).colorScheme;
    // Access the current theme's text styles
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.pop(context), // Allows user to close the sign-up page
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display error message if present in authState
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    authState.error!,
                    style: TextStyle(
                      color: colorScheme.error,
                    ), // Uses theme's error color
                  ),
                ),
              const SizedBox(height: 16),
              // Profile image selection area
              Center(
                child: GestureDetector(
                  onTap: _pickImage, // Call function to pick image on tap
                  child: Stack(
                    clipBehavior: Clip
                        .none, // Allows children to overflow the stack boundaries
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 2,
                          ), // Uses theme's outline color
                        ),
                        child: ClipOval(
                          child: authState.isUploadingImage
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme
                                        .primary, // Uses theme's primary color
                                  ),
                                )
                              : authState.profileImage != null
                              ? Image.file(
                                  // Display picked image
                                  authState.profileImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        // Fallback for image loading error
                                        color: colorScheme
                                            .surfaceVariant, // Uses theme's surface variant color
                                        child: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: colorScheme
                                              .onSurfaceVariant, // Uses theme's on surface variant color
                                        ),
                                      ),
                                )
                              : Icon(
                                  // Default icon if no image picked
                                  Icons.person,
                                  size: 40,
                                  color: colorScheme
                                      .onSurfaceVariant, // Uses theme's on surface variant color
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme
                                .primary, // Uses theme's primary color for edit button background
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.background,
                              width: 2,
                            ), // Uses theme's background color for border
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: colorScheme
                                .onPrimary, // Uses theme's on primary color for edit icon
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Username text field
              ReusableTextField(
                label: "Username",
                hintText: "Enter your username",
                controller: _usernameController,
                onChanged: (value) =>
                    ref.read(authProvider.notifier).updateUsername(value),
              ),
              const SizedBox(height: 16),
              // Email text field
              ReusableTextField(
                label: "Email",
                hintText: "Enter your email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) =>
                    ref.read(authProvider.notifier).updateEmail(value),
              ),
              const SizedBox(height: 16),
              // Password text field
              ReusableTextField(
                label: "Password",
                hintText: "Enter your password",
                obscureText: true,
                controller: _passwordController,
                onChanged: (value) =>
                    ref.read(authProvider.notifier).updatePassword(value),
              ),
              const SizedBox(height: 32),
              // Sign Up button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : _signUp, // Disable button while loading
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: authState.isLoading
                      ? CircularProgressIndicator(
                          color: colorScheme
                              .onPrimary, // Uses theme's on primary color for progress indicator
                        )
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // "OR" divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "OR",
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant, // Uses theme's on surface variant color
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              // "Continue with Google" button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: authState.isLoading
                      ? null
                      : _signInWithGoogle, // Disable button while loading
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    side: BorderSide(
                      color: colorScheme.outline,
                    ), // Uses theme's outline color for border
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Placeholder for Google logo.
                      // In a real app, ensure 'assets/images/google_logo.png' exists
                      // and is declared in pubspec.yaml under 'assets:'.
                      Image.network(
                        'https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png',
                        colorBlendMode: BlendMode.dstATop,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme
                              .onSurface, // Uses theme's on surface color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // "Already have an account?" link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ), // Uses theme's on surface variant color
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                            color: colorScheme
                                .primary, // Uses theme's primary color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
