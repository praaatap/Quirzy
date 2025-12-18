import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quirzy/service/user_data_service.dart';

// ==========================================
// SETTINGS STATE
// ==========================================

class SettingsState {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool soundEnabled;
  final bool darkMode;
  final String language;
  final bool autoSaveProgress;
  final String navbarStyle;

  SettingsState({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.soundEnabled = true,
    this.darkMode = false,
    this.language = 'English',
    this.autoSaveProgress = true,
    this.navbarStyle = 'custom',
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? soundEnabled,
    bool? darkMode,
    String? language,
    bool? autoSaveProgress,
    String? navbarStyle,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      autoSaveProgress: autoSaveProgress ?? this.autoSaveProgress,
      navbarStyle: navbarStyle ?? this.navbarStyle,
    );
  }
}

// ==========================================
// SETTINGS PROVIDER
// ==========================================

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<SettingsState> {
  final _storage = const FlutterSecureStorage();

  @override
  SettingsState build() {
    _loadSettings();
    return SettingsState();
  }

  Future<void> _loadSettings() async {
    final notifications = await _storage.read(key: 'notifications_enabled');
    final emailNotif = await _storage.read(key: 'email_notifications');
    final sound = await _storage.read(key: 'sound_enabled');
    final darkMode = await _storage.read(key: 'dark_mode');
    final language = await _storage.read(key: 'language');
    final autoSave = await _storage.read(key: 'auto_save');
    final navbarStyle = await _storage.read(key: 'navbar_style');

    state = SettingsState(
      notificationsEnabled: notifications == 'true',
      emailNotifications: emailNotif != 'false',
      soundEnabled: sound != 'false',
      darkMode: darkMode == 'true',
      language: language ?? 'English',
      autoSaveProgress: autoSave != 'false',
      navbarStyle: navbarStyle ?? 'custom',
    );
  }

  Future<void> toggleNotifications(bool value) async {
    await _storage.write(key: 'notifications_enabled', value: value.toString());
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> toggleEmailNotifications(bool value) async {
    await _storage.write(key: 'email_notifications', value: value.toString());
    state = state.copyWith(emailNotifications: value);
  }

  Future<void> toggleSound(bool value) async {
    await _storage.write(key: 'sound_enabled', value: value.toString());
    state = state.copyWith(soundEnabled: value);
  }

  Future<void> toggleDarkMode(bool value) async {
    await _storage.write(key: 'dark_mode', value: value.toString());
    state = state.copyWith(darkMode: value);
  }

  Future<void> setLanguage(String value) async {
    await _storage.write(key: 'language', value: value);
    state = state.copyWith(language: value);
  }

  Future<void> toggleAutoSave(bool value) async {
    await _storage.write(key: 'auto_save', value: value.toString());
    state = state.copyWith(autoSaveProgress: value);
  }

  Future<void> setNavbarStyle(String style) async {
    await _storage.write(key: 'navbar_style', value: style);
    state = state.copyWith(navbarStyle: style);
  }
}

// ==========================================
// ANIMATED WIDGET
// ==========================================

class _AnimatedSettingsWidget extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedSettingsWidget({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<_AnimatedSettingsWidget> createState() =>
      _AnimatedSettingsWidgetState();
}

class _AnimatedSettingsWidgetState extends State<_AnimatedSettingsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

// ==========================================
// SETTINGS SCREEN
// ==========================================

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _userDataService = UserDataService();
  final _storage = const FlutterSecureStorage(); // Added storage for logout
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);

    final List<Widget> settingSections = [
      // Appearance Section
      _AnimatedSettingsWidget(
        key: const ValueKey('Appearance'),
        child: _buildSection(
          theme: theme,
          isDark: isDark,
          title: 'Appearance',
          children: [
            _buildSwitchTile(
              theme: theme,
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Use dark theme',
              value: settings.darkMode,
              color: Colors.indigo,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleDarkMode(value);
              },
            ),
            Divider(
                height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildNavigationTile(
              theme: theme,
              icon: Icons.language,
              title: 'Language',
              subtitle: settings.language,
              color: Colors.green,
              onTap: () => _showLanguageDialog(theme),
            ),
            Divider(
                height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildNavigationTile(
              theme: theme,
              icon: Icons.navigation,
              title: 'Navigation Bar Style',
              subtitle: settings.navbarStyle == 'material3'
                  ? 'Material 3'
                  : 'Custom Modern',
              color: Colors.deepPurple,
              onTap: () => _showNavbarStyleDialog(theme, settings.navbarStyle),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // Notifications Section
      _AnimatedSettingsWidget(
        key: const ValueKey('Notifications'),
        delay: 100,
        child: _buildSection(
          theme: theme,
          isDark: isDark,
          title: 'Notifications',
          children: [
            _buildSwitchTile(
              theme: theme,
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive quiz reminders and updates',
              value: settings.notificationsEnabled,
              color: Colors.blue,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleNotifications(value);
              },
            ),
            Divider(
                height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildSwitchTile(
              theme: theme,
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Get updates via email',
              value: settings.emailNotifications,
              color: Colors.orange,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .toggleEmailNotifications(value);
              },
            ),
            Divider(
                height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildSwitchTile(
              theme: theme,
              icon: Icons.volume_up,
              title: 'Sound Effects',
              subtitle: 'Play sounds for answers',
              value: settings.soundEnabled,
              color: Colors.purple,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleSound(value);
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // Quiz Preferences
      _AnimatedSettingsWidget(
        key: const ValueKey('QuizPrefs'),
        delay: 200,
        child: _buildSection(
          theme: theme,
          isDark: isDark,
          title: 'Quiz Preferences',
          children: [
            _buildSwitchTile(
              theme: theme,
              icon: Icons.save,
              title: 'Auto-save Progress',
              subtitle: 'Automatically save quiz progress',
              value: settings.autoSaveProgress,
              color: Colors.teal,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleAutoSave(value);
              },
            ),
            Divider(
                height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildNavigationTile(
              theme: theme,
              icon: Icons.timer,
              title: 'Default Time Limit',
              subtitle: '30 seconds per question',
              color: Colors.amber,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Time settings coming soon!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // Data & Privacy
      _AnimatedSettingsWidget(
        key: const ValueKey('DataPrivacy'),
        delay: 300,
        child: _buildSection(
          theme: theme,
          isDark: isDark,
          title: 'Data & Privacy',
          children: [
            _buildNavigationTile(
              theme: theme,
              icon: Icons.download_rounded,
              title: 'Download My Data',
              subtitle: 'Export all your data as JSON',
              color: Colors.blue,
              onTap: _isDownloading ? () {} : () => _handleDownloadData(),
            ),
            Divider(
                height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildNavigationTile(
              theme: theme,
              icon: Icons.delete_forever,
              title: 'Clear Quiz History',
              subtitle: 'Delete all completed quizzes',
              color: Colors.orange,
              onTap: () => _showClearHistoryDialog(theme),
            ),
            Divider(
                height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildNavigationTile(
              theme: theme,
              icon: Icons.block,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              color: Colors.red,
              isDestructive: true,
              onTap: () => _showDeleteAccountDialog(theme),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // NEW: Modern Logout Button
      _AnimatedSettingsWidget(
        key: const ValueKey('Logout'),
        delay: 400,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: InkWell(
            onTap: () => _showLogoutDialog(context, theme),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded,
                      color: theme.colorScheme.error, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Log Out',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 40),
    ];

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background
          RepaintBoundary(
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary
                          .withOpacity(isDark ? 0.05 : 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.secondary
                          .withOpacity(isDark ? 0.04 : 0.06),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                stretch: true,
                expandedHeight: 100,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return settingSections[index];
                    },
                    childCount: settingSections.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  Widget _buildSection({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ),
        RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isDestructive ? color : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODERN LOGOUT DIALOG
  // ==========================================
  void _showLogoutDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large Animated Icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        size: 40,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Text Content
              Text(
                'Log Out',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to log out of Quirzy?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color:
                                theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. Clear secure storage
                        await _storage.deleteAll();

                        // 2. Close dialog
                        if (context.mounted) Navigator.pop(context);

                        // 3. Navigate (Replace with your route logic)
                        // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Logged out successfully',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.black87,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadowColor:
                            theme.colorScheme.error.withOpacity(0.4),
                      ),
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDownloadData() async {
    if (_isDownloading) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download_rounded,
                  color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Download Your Data',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will download:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildDataItem('✓ Profile information'),
            _buildDataItem('✓ All quizzes and questions'),
            _buildDataItem('✓ Quiz results and history'),
            _buildDataItem('✓ Challenges sent and received'),
            _buildDataItem('✓ App settings'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File will be saved as JSON in your Downloads folder',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Download',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDownloading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 20),
                Text(
                  'Downloading your data...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a moment',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await _userDataService.downloadUserData();

    setState(() => _isDownloading = false);

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.green, size: 28),
                ),
                const SizedBox(width: 12),
                const Text('Success!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['message'] ?? 'Data downloaded successfully!',
                  style: GoogleFonts.poppins(),
                ),
                if (result['filename'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.file_present,
                                size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result['filename'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Saved in Downloads folder',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to download data',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _handleDownloadData(),
            ),
          ),
        );
      }
    }
  }

  Widget _buildDataItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
  }

  void _showNavbarStyleDialog(ThemeData theme, String currentStyle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Navigation Bar Style',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavbarStyleOption(
              title: 'Material 3',
              description: 'Standard Material Design navigation',
              value: 'material3',
              currentValue: currentStyle,
              icon: Icons.navigation,
            ),
            const SizedBox(height: 12),
            _buildNavbarStyleOption(
              title: 'Custom Modern',
              description: 'Floating liquid sliding navbar',
              value: 'custom',
              currentValue: currentStyle,
              icon: Icons.auto_awesome,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbarStyleOption({
    required String title,
    required String description,
    required String value,
    required String currentValue,
    required IconData icon,
  }) {
    final isSelected = value == currentValue;

    return InkWell(
      onTap: () {
        ref.read(settingsProvider.notifier).setNavbarStyle(value);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Navigation style changed! Go back to see it.',
              style: GoogleFonts.poppins(),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Select Language',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German', 'Hindi']
              .map((lang) {
            return ListTile(
              title: Text(lang, style: GoogleFonts.poppins()),
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage(lang);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearHistoryDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.orange),
            const SizedBox(width: 12),
            Text('Clear History?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'This will delete all your quiz history. This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Clear', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            Text('Delete Account?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'This will permanently delete your account and all data. This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}