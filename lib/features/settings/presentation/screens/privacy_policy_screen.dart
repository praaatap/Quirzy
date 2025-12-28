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
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.privacy_tip_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quirzy Privacy Policy',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Last updated: December 20, 2025',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            _buildSection(
              theme,
              '1. Introduction',
              'Welcome to Quirzy ("we," "our," or "us"). This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application Quirzy (the "App"). Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the App.\n\nWe reserve the right to make changes to this Privacy Policy at any time and for any reason. We will alert you about any changes by updating the "Last updated" date of this Privacy Policy.',
            ),

            // Information We Collect
            _buildSection(
              theme,
              '2. Information We Collect',
              '''We may collect information about you in a variety of ways. The information we may collect via the App includes:

Personal Data:
• Email address (when you create an account or sign in with Google)
• Display name and username
• Profile picture (if provided through Google Sign-In)

Usage Data:
• Quiz topics and preferences
• Quiz scores and performance history
• Flashcard sets you create and study
• App usage patterns and interaction data

Device Data:
• Device type and operating system
• Unique device identifiers
• IP address (collected by our servers)
• Time zone and locale settings''',
            ),

            // How We Use Your Information
            _buildSection(
              theme,
              '3. How We Use Your Information',
              '''We use the information we collect for the following purposes:

• To provide and maintain our Service, including quiz generation and flashcard features
• To save your quiz history and track your learning progress
• To personalize your experience and provide tailored quiz recommendations
• To send you notifications about your learning progress (if enabled)
• To improve our App's functionality and user experience
• To analyze usage patterns and optimize our AI quiz generation
• To respond to your comments, questions, and support requests
• To detect, prevent, and address technical issues or fraudulent activity
• To comply with legal obligations''',
            ),

            // AI and Quiz Generation
            _buildSection(
              theme,
              '4. AI Quiz Generation',
              '''Quirzy uses artificial intelligence (AI) to generate quizzes and flashcards based on topics you provide. When you request a quiz:

• Your topic input is sent to our servers for processing
• We use third-party AI services (OpenAI/Google Gemini) to generate questions
• The generated content is stored in your account for future access
• We do not use your quiz topics to train AI models
• Quiz content is associated with your account and not shared publicly

The AI-generated content is educational in nature and we strive to ensure accuracy, but we cannot guarantee that all generated information is correct.''',
            ),

            // Data Storage and Security
            _buildSection(
              theme,
              '5. Data Storage and Security',
              '''We implement appropriate technical and organizational security measures to protect your personal information, including:

• Secure HTTPS encryption for all data transmission
• Encrypted storage of sensitive account credentials
• Secure token-based authentication
• Regular security audits of our systems
• Access controls limiting employee access to user data

Your data is stored on secure cloud servers. While we use commercially acceptable means to protect your Personal Data, no method of transmission over the Internet or electronic storage is 100% secure.''',
            ),

            // Third-Party Services
            _buildSection(
              theme,
              '6. Third-Party Services',
              '''Our App uses the following third-party services that may collect information:

Google Sign-In:
• We use Google Sign-In for authentication
• Google's privacy policy applies to data collected during sign-in
• We receive your name, email, and profile picture from Google

Google AdMob:
• We display ads to support free features
• AdMob may collect device identifiers and usage data
• You can opt out of personalized ads in your device settings

Analytics:
• We may collect anonymous usage statistics to improve the App
• This data is aggregated and cannot identify individual users''',
            ),

            // Data Retention
            _buildSection(
              theme,
              '7. Data Retention',
              '''We retain your personal information for as long as your account is active or as needed to provide you services. Specifically:

• Account data: Retained until you delete your account
• Quiz history: Retained for 1 year or until account deletion
• Flashcard sets: Retained until you delete them or your account
• Usage logs: Retained for 90 days for security purposes

You can request deletion of your data at any time by contacting us or deleting your account through the App settings.''',
            ),

            // Your Rights
            _buildSection(
              theme,
              '8. Your Rights',
              '''Depending on your location, you may have the following rights regarding your personal data:

• Right to Access: Request a copy of your personal data
• Right to Rectification: Correct inaccurate or incomplete data
• Right to Erasure: Request deletion of your personal data
• Right to Restrict Processing: Limit how we use your data
• Right to Data Portability: Receive your data in a portable format
• Right to Withdraw Consent: Withdraw consent for data processing

To exercise any of these rights, please contact us at privacy@quirzy.app or use the in-app settings to manage your account and data.''',
            ),

            // Children's Privacy
            _buildSection(
              theme,
              '9. Children\'s Privacy',
              '''Quirzy is intended for users of all ages for educational purposes. However:

• We do not knowingly collect personal information from children under 13 without parental consent
• If you are under 13, please have your parent or guardian create an account for you
• Parents can contact us to review, delete, or stop collection of their child's data
• If we learn we have collected data from a child under 13 without verification of parental consent, we will delete that information promptly

If you believe we might have any information from or about a child under 13, please contact us immediately.''',
            ),

            // International Users
            _buildSection(
              theme,
              '10. International Data Transfers',
              '''Quirzy is operated from India. If you are accessing the App from outside India, please be aware that your information may be transferred to, stored, and processed in India or other countries where our servers are located.

By using the App, you consent to the transfer of information to countries outside of your country of residence, which may have different data protection rules than those of your country.''',
            ),

            // Changes to Privacy Policy
            _buildSection(
              theme,
              '11. Changes to This Privacy Policy',
              '''We may update this Privacy Policy from time to time. We will notify you of any changes by:

• Posting the new Privacy Policy on this page
• Updating the "Last updated" date at the top
• Sending you an in-app notification for significant changes

You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.''',
            ),

            // Contact Us
            _buildSection(
              theme,
              '12. Contact Us',
              '''If you have any questions about this Privacy Policy, please contact us:
Developer: Pratap Singh
Location: India

For data deletion requests or privacy concerns, please use the subject line "Privacy Request" in your email.''',
            ),

            const SizedBox(height: 24),

            // View Online Button
            Center(
              child: Column(
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(
                        'https://quirzy-privacy-policy.xeyenx69.workers.dev/',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(
                      'View Full Policy Online',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'By using Quirzy, you agree to this Privacy Policy',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.7,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
