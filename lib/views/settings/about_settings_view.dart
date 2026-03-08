import 'package:flutter/material.dart';

class AboutSettingsView extends StatelessWidget {
  const AboutSettingsView({super.key});

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          onTap: () => _showInfoDialog(
            context,
            'About Orgaa',
            'Version 1.0.0\n\nThis is a sample application.',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () => _showInfoDialog(
            context,
            'Privacy Policy',
            'This is a placeholder for the privacy policy.',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms of Service'),
          onTap: () => _showInfoDialog(
            context,
            'Terms of Service',
            'This is a placeholder for the terms of service.',
          ),
        ),
      ],
    );
  }
}
