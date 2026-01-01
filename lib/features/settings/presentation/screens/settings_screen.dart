import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:quirzy/features/settings/services/user_data_service.dart';
import '../../providers/settings_provider.dart';
import '../widgets/settings_widgets.dart';
import '../widgets/settings_tiles.dart';
import '../widgets/settings_dialogs.dart';
import 'package:quirzy/features/settings/services/data_download_handler.dart';

// ==========================================
// SETTINGS SCREEN (Refactored)
// ==========================================

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _userDataService = UserDataService();
  final _storage = const FlutterSecureStorage();
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Premium Blur Background
          _buildBackground(theme, isDark),

          // Main content
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              _buildAppBar(theme),
              _buildHeader(theme),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildSettingsSections(theme, isDark, settings),
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
  // BACKGROUND
  // ==========================================

  Widget _buildBackground(ThemeData theme, bool isDark) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Top gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.14),
                    theme.colorScheme.tertiary.withOpacity(
                      isDark ? 0.05 : 0.08,
                    ),
                    theme.scaffoldBackgroundColor.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          // Top-right blur blob
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.25),
                    theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.12),
                    theme.colorScheme.primary.withOpacity(0),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          // Bottom-left blur blob
          Positioned(
            bottom: 200,
            left: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.tertiary.withOpacity(
                      isDark ? 0.12 : 0.15,
                    ),
                    theme.colorScheme.tertiary.withOpacity(
                      isDark ? 0.06 : 0.08,
                    ),
                    theme.colorScheme.tertiary.withOpacity(0),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                    blurRadius: 80,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // APP BAR
  // ==========================================

  SliverAppBar _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================

  SliverToBoxAdapter _buildHeader(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gradient headline
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  theme.colorScheme.onSurface,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ).createShader(bounds),
              child: Text(
                'Customize Your\nExperience',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Feature badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                SettingsBadge(
                  icon: Icons.color_lens_rounded,
                  label: 'Appearance',
                  color: Colors.indigo,
                ),
                SettingsBadge(
                  icon: Icons.notifications_rounded,
                  label: 'Alerts',
                  color: Colors.orange,
                ),
                SettingsBadge(
                  icon: Icons.security_rounded,
                  label: 'Privacy',
                  color: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SETTINGS SECTIONS
  // ==========================================

  List<Widget> _buildSettingsSections(
    ThemeData theme,
    bool isDark,
    SettingsState settings,
  ) {
    return [
      // Appearance Section
      AnimatedSettingsWidget(
        child: SettingsSection(
          theme: theme,
          isDark: isDark,
          title: 'Appearance',
          children: [
            SettingsSwitchTile(
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
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            SettingsNavigationTile(
              theme: theme,
              icon: Icons.language,
              title: 'Language',
              subtitle: settings.language,
              color: Colors.green,
              onTap: () => showLanguageDialog(context, theme, ref),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // Notifications Section
      AnimatedSettingsWidget(
        delay: 100,
        child: SettingsSection(
          theme: theme,
          isDark: isDark,
          title: 'Notifications',
          children: [
            SettingsSwitchTile(
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
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            SettingsSwitchTile(
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
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            SettingsSwitchTile(
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
      AnimatedSettingsWidget(
        delay: 200,
        child: SettingsSection(
          theme: theme,
          isDark: isDark,
          title: 'Quiz Preferences',
          children: [
            SettingsSwitchTile(
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
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            SettingsNavigationTile(
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
      AnimatedSettingsWidget(
        delay: 300,
        child: SettingsSection(
          theme: theme,
          isDark: isDark,
          title: 'Data & Privacy',
          children: [
            SettingsNavigationTile(
              theme: theme,
              icon: Icons.download_rounded,
              title: 'Download My Data',
              subtitle: 'Export all your data as JSON',
              color: Colors.blue,
              onTap: _isDownloading ? () {} : () => _handleDownloadData(),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            SettingsNavigationTile(
              theme: theme,
              icon: Icons.delete_forever,
              title: 'Clear Quiz History',
              subtitle: 'Delete all completed quizzes',
              color: Colors.orange,
              onTap: () => showClearHistoryDialog(context, theme),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            SettingsNavigationTile(
              theme: theme,
              icon: Icons.block,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              color: Colors.red,
              isDestructive: true,
              onTap: () => showDeleteAccountDialog(context, theme),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // Logout Button
      AnimatedSettingsWidget(
        delay: 400,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: InkWell(
            onTap: () => showLogoutDialog(context, theme, _storage),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
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
  }

  // ==========================================
  // HANDLERS
  // ==========================================

  Future<void> _handleDownloadData() async {
    final handler = DataDownloadHandler(
      context: context,
      userDataService: _userDataService,
    );
    await handler.handleDownloadData(
      onStateChange: () {
        if (mounted) {
          setState(() {
            _isDownloading = handler.isDownloading;
          });
        }
      },
    );
  }
}
