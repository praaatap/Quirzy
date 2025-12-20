import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: December 2025',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              'Information We Collect',
              'We collect information you provide directly, such as your email address and username when you create an account. We also collect quiz data and scores to provide our services.',
            ),
            _buildSection(
              theme,
              'How We Use Your Information',
              'We use your information to provide, maintain, and improve our services. This includes saving your quiz history and providing personalized quiz recommendations.',
            ),
            _buildSection(
              theme,
              'Data Security',
              'We implement appropriate security measures to protect your personal information. Your data is encrypted and stored securely on our servers.',
            ),
            _buildSection(
              theme,
              'Your Rights',
              'You have the right to access, update, or delete your personal information at any time. Contact us if you have any questions about your data.',
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () async {
                  final uri = Uri.parse(
                    'https://quirzy-privacy-policy.xeyenx69.workers.dev/',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  'View Full Privacy Policy Online',
                  style: GoogleFonts.poppins(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              height: 1.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
