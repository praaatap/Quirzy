import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 1; // 0: Monthly, 1: Yearly

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -100,
            child:
                Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF5B13EC).withOpacity(0.2),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/noise.png',
                          ), // Optional noise texture
                          opacity: 0.1,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .animate()
                    .scale(duration: 2000.ms, curve: Curves.easeInOut)
                    .fadeIn(),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: textColor,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white10
                              : Colors.grey.shade100,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFFFD700)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.black87,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PRO',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: Colors.black87,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Key Value Prop
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Unlock Your\nFull Potential 🚀',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Get unlimited access to everything.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white54
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),

                  const SizedBox(height: 48),

                  // Carousel or List of Benefits
                  _buildBenefitRow(
                    Icons.auto_awesome_rounded,
                    'Unlimited AI Quizzes',
                    'Generate quizzes on any topic instantly.',
                    isDark,
                  ),
                  _buildBenefitRow(
                    Icons.school_rounded,
                    'Exam Specific Content',
                    'Access premium JEE, NEET, & MBA sets.',
                    isDark,
                  ),
                  _buildBenefitRow(
                    Icons.block_rounded,
                    'No Ads',
                    'Enjoy a completely distraction-free experience.',
                    isDark,
                  ),
                  _buildBenefitRow(
                    Icons.analytics_rounded,
                    'Advanced Analytics',
                    'Track your progress with detailed insights.',
                    isDark,
                  ),

                  const SizedBox(height: 48),

                  // Plan Selection
                  Text(
                    'Choose your plan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildPlanCard(
                          context,
                          index: 0,
                          title: 'Monthly',
                          price: '₹299',
                          period: '/mo',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPlanCard(
                          context,
                          index: 1,
                          title: 'Yearly',
                          price: '₹2,999',
                          period: '/yr',
                          isGeneric: false,
                          isBestValue: true,
                          saveText: 'Save 20%',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Mock Payment Logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment Gateway Coming Soon! 💳'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B13EC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF5B13EC).withOpacity(0.5),
                      ),
                      child: Text(
                        _selectedPlan == 0
                            ? 'Start Monthly Plan'
                            : 'Start Yearly Plan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ).animate().scale(
                    delay: 400.ms,
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Cancel anytime. Terms apply.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5B13EC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF5B13EC), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required int index,
    required String title,
    required String price,
    required String period,
    bool isGeneric = true,
    bool isBestValue = false,
    String? saveText,
    required bool isDark,
  }) {
    final isSelected = _selectedPlan == index;
    final borderColor = isSelected
        ? const Color(0xFF5B13EC)
        : Colors.transparent;
    final bgColor = isDark
        ? (isSelected
              ? const Color(0xFF5B13EC).withOpacity(0.1)
              : const Color(0xFF1A1A1A))
        : (isSelected
              ? const Color(0xFF5B13EC).withOpacity(0.05)
              : Colors.grey.shade50);

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF5B13EC).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      period,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isBestValue)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFFD700)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    saveText ?? 'BEST VALUE',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
