import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/screen/introduction/welcome.dart';
import 'package:quirzy/screen/settings/settings_screen.dart';
import 'package:quirzy/screen/privacy/privacyPolicy.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  String _userName = 'Quiz Master';
  String _userEmail = 'user@quirzy.com';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final name = await _storage.read(key: 'user_name').timeout(const Duration(seconds: 3), onTimeout: () => null);
      final email = await _storage.read(key: 'user_email').timeout(const Duration(seconds: 3), onTimeout: () => null);

      if (!mounted) return;
      setState(() {
        _userName = name?.trim().isNotEmpty == true ? name! : 'Quiz Master';
        _userEmail = email?.trim().isNotEmpty == true ? email! : 'user@quirzy.com';
        _isLoading = false;
      });

      await _animationController.forward();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      await _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Ambient Background (Matches Sign In/Up)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.15),
                    theme.colorScheme.primary.withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            
                            // 2. Profile Header
                            ProfileHeader(userName: _userName, userEmail: _userEmail),
                            
                            const SizedBox(height: 40),
                            
                            // 3. Section Title
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Account",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 4. Menu Options
                            _buildMenuTile(
                              theme,
                              icon: Icons.security_rounded,
                              title: 'Privacy & Security',
                              color: Colors.teal,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                            ),
                            const SizedBox(height: 12),
                            _buildMenuTile(
                              theme,
                              icon: Icons.info_outline_rounded,
                              title: 'About Quirzy',
                              color: Colors.orange,
                              onTap: () => _showAboutDialog(theme),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // 5. Logout Button
                            _buildLogoutButton(theme),
                            
                            // Bottom padding for Navbar
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
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
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) => SizedBox(
    width: double.infinity,
    height: 56,
    child: OutlinedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        _showLogoutDialog();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
        side: BorderSide(color: theme.colorScheme.error.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 20, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Text(
            'Log Out',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _showAboutDialog(ThemeData theme) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: theme.colorScheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.quiz_rounded, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Text('About Quirzy', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('A smart quiz generation app powered by AI technology to help you master any subject.', style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.5, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Log Out?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to log out of your account?', style: GoogleFonts.plusJakartaSans(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Log Out', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await ref.read(authProvider.notifier).logout();

    if (!mounted) return;
    Navigator.of(context).pop(); // Dismiss loading
    
    // Navigate to Welcome
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const QuiryHome()),
      (route) => false,
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfileHeader({super.key, required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarLetter = (userName.isNotEmpty) ? userName[0].toUpperCase() : 'Q';
    
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.primary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              avatarLetter,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}