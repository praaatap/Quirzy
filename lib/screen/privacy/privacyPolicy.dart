import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We access Theme here, but child widgets handle their own styling
    // to allow us to use const constructors for layout structure.
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: const Stack(
        children: [
          // 1. Static Background (Won't rebuild on scroll)
          _BackgroundDecorations(),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),

                  // Header Badge
                  _LastUpdatedBadge(),

                  SizedBox(height: 30),

                  // SECTIONS (All Const)
                  _PolicySection(
                    title: 'Introduction',
                    content:
                        'Welcome to Quirzy ("we," "our," or "us"). This Privacy Policy explains how we collect, use, disclosure, and safeguard your information when you use our mobile application. By using Quirzy, you consent to the data practices described in this policy.',
                  ),

                  _PolicySection(
                    title: '1. Information We Collect',
                    content: '', // Header only
                  ),

                  _PolicySubSection(
                    title: '1.1 Personal Information',
                    content:
                        'We collect information you provide voluntarily when creating an account:\n\n• Name and Email address\n• Authentication data (via Google Sign-In)\n• Profile information (Username)',
                  ),

                  _PolicySubSection(
                    title: '1.2 Usage and Content Data',
                    content:
                        'To provide AI-generated quizzes, we process:\n\n• Topics and text inputs you submit\n• Quiz results and performance scores\n• App interaction logs',
                  ),

                  _PolicySubSection(
                    title: '1.3 Device & Advertising Data',
                    content:
                        'We and our partners (Google AdMob) collect specific device data to serve personalized ads:\n\n• Advertising IDs (Android Advertising ID / iOS IDFA)\n• Device model, OS version, and IP address\n• General location data',
                  ),

                  _PolicySection(
                    title: '2. How We Use Your Information',
                    content:
                        'We use your data for the following purposes:\n\n'
                        '• To generate educational quizzes via AI (Gemini)\n'
                        '• To manage your account and login sessions\n'
                        '• To serve personalized advertisements via Google AdMob\n'
                        '• To analyze app performance and crash reports\n'
                        '• To facilitate account deletion requests',
                  ),

                  _PolicySection(
                    title: '3. Data Sharing & Third Parties',
                    content:
                        'We share data with the following trusted third-party service providers:\n\n'
                        '• **Google AdMob:** Collects Advertising IDs to show relevant ads.\n'
                        '• **Google Gemini (AI):** Processes user-submitted text/topics to generate quiz questions.\n'
                        '• **Firebase:** Handles secure authentication and database storage.',
                  ),

                  _PolicySection(
                    title: '4. Account Deletion',
                    content:
                        'You have the right to delete your account and all associated data at any time. When you request deletion, your profile, quiz history, and personal data will be permanently removed from our servers.\n\n'
                        '**How to delete your account:**\n\n'
                        '1. **In-App:** Go to Settings > Delete Account.\n'
                        '2. **Web Request:** Visit our dedicated deletion portal at:\n'
                        'https://quirzy-account-delete.vercel.app/\n\n'
                        'Data deletion requests are processed immediately or within the timeframe mandated by local laws.',
                  ),

                  _PolicySection(
                    title: '5. Children\'s Privacy',
                    content:
                        'Quirzy is not directed to children under the age of 13. We do not knowingly collect personal information from children under 13. If we discover that a child under 13 has provided us with personal information, we will delete such information from our servers immediately.',
                  ),

                  _PolicySection(
                    title: '6. Data Retention',
                    content:
                        'We retain your personal information only as long as your account is active or as needed to provide you with our services. If you delete your account using the methods described in Section 4, your data is deleted from our active databases.',
                  ),

                  _PolicySection(
                    title: '7. Contact Us',
                    content:
                        'If you have questions about this Privacy Policy or need assistance with your data, please contact us at:\n\n'
                        'Email: pratap.09082005@gmail.com',
                  ),

                  SizedBox(height: 20),

                  // Consent Footer
                  _ConsentCard(),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// OPTIMIZED WIDGETS (CONST CAPABLE)
// ==========================================

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine colors here, but the Widget structure is const in the parent
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}

class _LastUpdatedBadge extends StatelessWidget {
  const _LastUpdatedBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Last updated: December 03, 2025',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (content.isNotEmpty)
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.8,
              ),
            ),
        ],
      ),
    );
  }
}

class _PolicySubSection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySubSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: theme.colorScheme.primary,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'Your Privacy Matters',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'By using Quirzy, you agree to the collection and use of information in accordance with this policy.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}