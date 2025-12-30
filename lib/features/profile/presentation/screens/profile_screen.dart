import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:quirzy/routes/app_routes.dart';
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/features/settings/providers/settings_provider.dart';
import 'package:quirzy/providers/quiz_history_provider.dart';

// ==========================================
// REDESIGNED PROFILE SCREEN
// Full Dark/Light Theme Support
// ==========================================

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  String _userName = 'Quiz Master';
  String _userEmail = 'user@quirzy.com';
  bool _isLoading = true;

  // Static colors
  static const primaryColor = Color(0xFF5B13EC);
  static const primaryLight = Color(0xFFEFE9FD);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final name = await _storage.read(key: 'user_name');
      final email = await _storage.read(key: 'user_email');

      if (!mounted) return;
      setState(() {
        _userName = name?.isNotEmpty == true ? name! : 'Quiz Master';
        _userEmail = email?.isNotEmpty == true ? email! : 'user@quirzy.com';
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settingsState = ref.watch(settingsProvider);
    final historyState = ref.watch(quizHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final bgColor = isDark ? const Color(0xFF161022) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF1E1730) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? const Color(0xFFA78BFA) : const Color(0xFF664C9A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : FadeTransition(
                opacity: _fadeAnim,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(textMain)),
                    SliverToBoxAdapter(
                      child: _buildProfileCard(
                        isDark,
                        surfaceColor,
                        textMain,
                        textSub,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildStatsCards(
                        historyState,
                        isDark,
                        surfaceColor,
                        textMain,
                        textSub,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildPreferencesSection(
                        settingsState,
                        isDark,
                        surfaceColor,
                        textMain,
                        textSub,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildNotificationsSection(
                        settingsState,
                        isDark,
                        surfaceColor,
                        textMain,
                        textSub,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildDataSection(
                        isDark,
                        surfaceColor,
                        textMain,
                        textSub,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildSupportSection(
                        isDark,
                        surfaceColor,
                        textMain,
                        textSub,
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildLogoutButton(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(Color textMain) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textMain,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          // Avatar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'Q',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textSub,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? primaryColor.withOpacity(0.2) : primaryLight,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_rounded, color: primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
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

  Widget _buildStatsCards(
    QuizHistoryState historyState,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    final totalQuizzes = historyState.quizzes.length;
    int totalScore = 0;
    int totalQuestions = 0;
    for (final quiz in historyState.quizzes) {
      totalScore += (quiz['score'] ?? 0) as int;
      totalQuestions +=
          (quiz['totalQuestions'] ?? quiz['questionCount'] ?? 0) as int;
    }
    final avgScore = totalQuestions > 0
        ? (totalScore / totalQuestions * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.quiz_rounded,
              label: 'QUIZZES',
              value: '$totalQuizzes',
              isPrimary: true,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textMain: textMain,
              textSub: textSub,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.trending_up_rounded,
              label: 'AVG SCORE',
              value: '$avgScore%',
              isPrimary: false,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textMain: textMain,
              textSub: textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isPrimary,
    required bool isDark,
    required Color surfaceColor,
    required Color textMain,
    required Color textSub,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, animValue, child) => Transform.scale(
        scale: 0.8 + (0.2 * animValue),
        child: Opacity(opacity: animValue, child: child),
      ),
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary
              ? (isDark
                    ? primaryColor.withOpacity(0.15)
                    : primaryLight.withOpacity(0.5))
              : surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary
              ? Border.all(color: primaryColor.withOpacity(isDark ? 0.3 : 0.1))
              : (isDark ? Border.all(color: const Color(0xFF2D2540)) : null),
          boxShadow: isPrimary || isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: isPrimary ? primaryColor : textSub),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textSub,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isPrimary ? primaryColor : textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(
    SettingsState settingsState,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    return _buildSection(
      title: 'Preferences',
      textMain: textMain,
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode_rounded,
          title: 'Dark Mode',
          subtitle: 'Easier on the eyes',
          value: settingsState.darkMode,
          iconColor: const Color(0xFF6366F1),
          isDark: isDark,
          surfaceColor: surfaceColor,
          textMain: textMain,
          textSub: textSub,
          onChanged: (val) =>
              ref.read(settingsProvider.notifier).toggleDarkMode(val),
        ),
        _buildSettingTile(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: settingsState.language,
          iconColor: const Color(0xFF10B981),
          isDark: isDark,
          surfaceColor: surfaceColor,
          textMain: textMain,
          textSub: textSub,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(
    SettingsState settingsState,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    return _buildSection(
      title: 'Notifications',
      textMain: textMain,
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_active_rounded,
          title: 'Push Notifications',
          subtitle: 'Daily reminders & updates',
          value: settingsState.notificationsEnabled,
          iconColor: const Color(0xFFF59E0B),
          isDark: isDark,
          surfaceColor: surfaceColor,
          textMain: textMain,
          textSub: textSub,
          onChanged: (val) =>
              ref.read(settingsProvider.notifier).toggleNotifications(val),
        ),
        _buildSwitchTile(
          icon: Icons.volume_up_rounded,
          title: 'Sound Effects',
          subtitle: 'Play sounds during quizzes',
          value: settingsState.soundEnabled,
          iconColor: const Color(0xFFEC4899),
          isDark: isDark,
          surfaceColor: surfaceColor,
          textMain: textMain,
          textSub: textSub,
          onChanged: (val) =>
              ref.read(settingsProvider.notifier).toggleSound(val),
        ),
      ],
    );
  }

  Widget _buildDataSection(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    return _buildSection(
      title: 'Data & Privacy',
      textMain: textMain,
      children: [
        _buildSettingTile(
          icon: Icons.download_rounded,
          title: 'Download My Data',
          subtitle: 'Export history as JSON',
          iconColor: const Color(0xFF3B82F6),
          isDark: isDark,
          surfaceColor: surfaceColor,
          textMain: textMain,
          textSub: textSub,
          onTap: () {},
        ),
        _buildSettingTile(
          icon: Icons.delete_forever_rounded,
          title: 'Clear History',
          subtitle: 'Remove all quiz records',
          iconColor: const Color(0xFFEF4444),
          isDark: isDark,
          surfaceColor: surfaceColor,
          textMain: textMain,
          textSub: textSub,
          onTap: () => _showClearHistoryDialog(),
        ),
      ],
    );
  }

  Widget _buildSupportSection(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    return _buildSection(
      title: 'Support',
      textMain: textMain,
      children: [
        _buildSettingTile(
          icon: Icons.info_outline_rounded,
          title: 'About Quirzy',
          subtitle: 'Version 1.0.0',
          iconColor: primaryColor,
          isDark: isDark,
          surfaceColor: surfaceColor,
          textMain: textMain,
          textSub: textSub,
          onTap: () {},
        ),
        _buildSettingTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Feedback',
          subtitle: 'Get support or send feedback',
          iconColor: const Color(0xFF10B981),
          isDark: isDark,
          surfaceColor: surfaceColor,
          textMain: textMain,
          textSub: textSub,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Color textMain,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isDark,
    required Color surfaceColor,
    required Color textMain,
    required Color textSub,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: const Color(0xFF2D2540)) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? iconColor.withOpacity(0.2)
                    : iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: textSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textSub.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color iconColor,
    required bool isDark,
    required Color surfaceColor,
    required Color textMain,
    required Color textSub,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: const Color(0xFF2D2540)) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? iconColor.withOpacity(0.2)
                  : iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: textSub,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFFEF4444).withOpacity(0.15)
                : const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEF4444).withOpacity(isDark ? 0.3 : 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Log Out',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1730) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF120D1B),
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF664C9A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: isDark
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF664C9A),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                // Use GoRouter to switch to auth route correctly
                context.go(AppRoutes.auth);
              }
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1730) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear History?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF120D1B),
          ),
        ),
        content: Text(
          'This will permanently delete all your quiz history. This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF664C9A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: isDark
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF664C9A),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'History cleared',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              'Clear',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
