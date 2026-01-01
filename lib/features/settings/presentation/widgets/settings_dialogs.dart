import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../providers/settings_provider.dart';

// ==========================================
// LOGOUT DIALOG
// ==========================================

void showLogoutDialog(
  BuildContext context,
  ThemeData theme,
  FlutterSecureStorage storage,
) {
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
                          color: theme.colorScheme.outline.withOpacity(0.3),
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
                      await storage.deleteAll();

                      // 2. Close dialog
                      if (context.mounted) Navigator.pop(context);

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
                      shadowColor: theme.colorScheme.error.withOpacity(0.4),
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

// ==========================================
// LANGUAGE DIALOG
// ==========================================

void showLanguageDialog(BuildContext context, ThemeData theme, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Select Language',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ['English', 'Spanish', 'French', 'German', 'Hindi'].map((
          lang,
        ) {
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

// ==========================================
// CLEAR HISTORY DIALOG
// ==========================================

void showClearHistoryDialog(BuildContext context, ThemeData theme) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.delete_forever, color: Colors.orange),
          const SizedBox(width: 12),
          Text(
            'Clear History?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
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

// ==========================================
// DELETE ACCOUNT DIALOG
// ==========================================

void showDeleteAccountDialog(BuildContext context, ThemeData theme) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 12),
          Text(
            'Delete Account?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
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
