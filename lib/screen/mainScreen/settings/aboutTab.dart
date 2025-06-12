import 'package:flutter/material.dart';
class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'App Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const ListTile(
          title: Text('App Version'),
          subtitle: Text('Version 1.2.3'),
        ),
        const Divider(),
        const ListTile(
          title: Text('Terms of Service'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        const ListTile(
          title: Text('Privacy Policy'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        const ListTile(
          title: Text('Contact Us'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        const SizedBox(height: 20),
        const Text('Credits', style: TextStyle(fontWeight: FontWeight.bold)),
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('This app was developed by the team at QuizGenius.'),
        ),
      ],
    );
  }
}