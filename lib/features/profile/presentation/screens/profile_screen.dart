import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quirzy/core/theme/app_theme.dart'; // ✅ Make sure app_theme.dart is saved!
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/features/settings/providers/settings_provider.dart';
import 'package:quirzy/providers/quiz_history_provider.dart';
import 'package:quirzy/features/auth/presentation/screens/welcome_screen.dart';
// import 'package:quirzy/features/settings/services/user_data_service.dart';
// import 'package:quirzy/features/settings/services/data_download_handler.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Profile State
  String _userName = 'Quiz Master';
  String _userEmail = 'user@quirzy.com';
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
  }

  Future<void> _loadUserData() async {
    try {
      final name = await _storage.read(key: 'user_name');
      final email = await _storage.read(key: 'user_email');

      if (!mounted) return;
      setState(() {
        _userName = name?.isNotEmpty == true ? name! : 'Quiz Master';
        _userEmail = email?.isNotEmpty == true ? email! : 'user@quirzy.com';
        _isLoadingProfile = false;
      });
      _animController.forward();
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = context.theme;
    final quizColors = context.quizColors;
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ),
        title: Text(
          'Account',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: quizColors.error),
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Premium Background
          const RepaintBoundary(child: _BackgroundDecoration()),

          // 2. Main Content
          if (_isLoadingProfile)
            Center(
              child: CircularProgressIndicator(color: theme.colorScheme.primary),
            )
          else
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // A. Top Padding for AppBar
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),

                    // B. Profile Header (Avatar/Name)
                    SliverToBoxAdapter(
                      child: _ProfileHeader(
                        userName: _userName,
                        userEmail: _userEmail,
                      ),
                    ),

                    // C. Stats Section
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    const SliverToBoxAdapter(child: _StatsSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),

                    // D. Settings Sections
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // --- Appearance ---
                          _SectionHeader(title: 'Preferences'),
                          _SwitchTile(
                            icon: Icons.dark_mode_rounded,
                            title: 'Dark Mode',
                            subtitle: 'Easier on the eyes',
                            value: settingsState.darkMode,
                            activeColor: theme.colorScheme.primary, // Blue
                            onChanged: (val) =>
                                ref.read(settingsProvider.notifier).toggleDarkMode(val),
                          ),
                          _SettingTile(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            subtitle: settingsState.language,
                            iconColor: quizColors.success, // Green
                            onTap: () {
                              // Language dialog logic
                            },
                          ),

                          // --- Notifications ---
                          const SizedBox(height: 24),
                          _SectionHeader(title: 'Notifications'),
                          _SwitchTile(
                            icon: Icons.notifications_active_rounded,
                            title: 'Push Notifications',
                            subtitle: 'Daily reminders & updates',
                            value: settingsState.notificationsEnabled,
                            activeColor: quizColors.warning, // Orange
                            onChanged: (val) => ref
                                .read(settingsProvider.notifier)
                                .toggleNotifications(val),
                          ),
                          _SwitchTile(
                            icon: Icons.volume_up_rounded,
                            title: 'Sound Effects',
                            subtitle: 'Play sounds during quizzes',
                            value: settingsState.soundEnabled,
                            activeColor: theme.colorScheme.secondary, // Cyan
                            onChanged: (val) =>
                                ref.read(settingsProvider.notifier).toggleSound(val),
                          ),

                          // --- Data & Privacy ---
                          const SizedBox(height: 24),
                          _SectionHeader(title: 'Data & Privacy'),
                          _SettingTile(
                            icon: Icons.download_rounded,
                            title: 'Download My Data',
                            subtitle: 'Export history as JSON',
                            iconColor: quizColors.info, // Blue Info
                            onTap: () {
                              // Call your DataDownloadHandler here
                            },
                          ),
                          _SettingTile(
                            icon: Icons.delete_forever_rounded,
                            title: 'Clear History',
                            subtitle: 'Remove all quiz records',
                            iconColor: quizColors.error, // Red
                            onTap: () => _showClearHistoryDialog(context),
                          ),

                          // --- Support ---
                          const SizedBox(height: 24),
                          _SectionHeader(title: 'Support'),
                          _SettingTile(
                            icon: Icons.info_outline_rounded,
                            title: 'About Quirzy',
                            subtitle: 'Version 1.0.0',
                            iconColor: theme.colorScheme.secondary, // Cyan
                            onTap: () {},
                          ),
                          _SettingTile(
                            icon: Icons.policy_rounded,
                            title: 'Privacy Policy',
                            subtitle: 'Read our terms',
                            iconColor: theme.colorScheme.onSurfaceVariant, // Grey
                            onTap: () {},
                          ),

                          // Bottom Padding
                          const SizedBox(height: 50),
                          
                          const SizedBox(height: 120),
                        ]),
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

  // --- Actions ---

  void _showLogoutDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.theme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const QuiryHome()),
                  (route) => false,
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.quizColors.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    // Implement similar to logout
  }
}

// ==========================================
// 🎨 WIDGETS (Internal for Simplicity)
// ==========================================

class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _ProfileHeader({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'Q';

    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          userName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // Email Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            userEmail,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends ConsumerWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final quizColors = context.quizColors;

    final totalQuizzes = ref.watch(quizHistoryProvider.select((s) => s.totalQuizzes));
    final averageScore = ref.watch(quizHistoryProvider.select((s) => s.averageScore));
    final correct = ref.watch(quizHistoryProvider.select((s) => s.totalCorrectAnswers));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              value: '$totalQuizzes',
              label: 'Quizzes',
              color: theme.colorScheme.primary,
            ),
            Container(width: 1, height: 40, color: theme.dividerColor),
            _StatItem(
              value: '${averageScore.toInt()}%',
              label: 'Avg Score',
              color: quizColors.warning,
            ),
            Container(width: 1, height: 40, color: theme.dividerColor),
            _StatItem(
              value: '$correct',
              label: 'Correct',
              color: quizColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: context.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.iconTheme.color?.withOpacity(0.3)),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: activeColor, size: 22),
        ),
        title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: Switch.adaptive(
          value: value,
          activeColor: activeColor,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _LargeLogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LargeLogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.logout_rounded, color: context.quizColors.error),
        label: Text('Log Out', style: TextStyle(color: context.quizColors.error, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.quizColors.error.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned(
          top: 0, left: 0, right: 0, height: 350,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.15),
                  theme.scaffoldBackgroundColor.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}