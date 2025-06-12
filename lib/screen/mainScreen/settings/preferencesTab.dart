import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/provider/settingsProvider.dart';


class PreferencesTab extends ConsumerWidget {
  const PreferencesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SwitchListTile(
          title: const Text('Quiz Reminders'),
          subtitle: const Text(
            'Receive notifications about new quizzes and updates',
          ),
          value: settings.quizReminders,
          onChanged: notifier.toggleQuizReminders,
        ),
        SwitchListTile(
          title: const Text('App Updates'),
          subtitle: const Text(
            'Get notified about app updates and new features',
          ),
          value: settings.appUpdates,
          onChanged: notifier.toggleAppUpdates,
        ),
        const SizedBox(height: 20),
        const Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
        ListTile(
          title: const Text('Theme'),
          subtitle: const Text('Choose between light and dark themes'),
          trailing: Text(settings.theme),
          onTap: () {
            // Show theme selection dialog
            notifier.changeTheme(settings.theme == 'Light' ? 'Dark' : 'Light');
          },
        ),
        ListTile(
          title: const Text('Font Size'),
          subtitle: const Text('Adjust the font size for better readability'),
          trailing: Text(settings.fontSize),
          onTap: () {
            // Show font size selection dialog
          },
        ),
        const SizedBox(height: 20),
        const Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
        ListTile(
          title: const Text('Language'),
          subtitle: const Text('Select your preferred language'),
          trailing: Text(settings.language),
          onTap: () {
            // Show language selection dialog
          },
        ),
      ],
    );
  }
}
