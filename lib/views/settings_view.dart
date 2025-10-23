import 'package:flutter/material.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.palette), text: 'Appearance'),
              Tab(icon: Icon(Icons.language), text: 'Language'),
              Tab(icon: Icon(Icons.info), text: 'About'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppearanceSettings(context),
            _buildLanguageSettings(),
            _buildAboutSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context) {
    return ListView(
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              secondary: const Icon(Icons.color_lens),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSettings() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: const Text('English'),
          onTap: () {
            // Show language selection dialog
          },
        ),
      ],
    );
  }

  Widget _buildAboutSettings() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          onTap: () {
            // Navigate to about screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () {
            // Navigate to privacy policy screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms of Service'),
          onTap: () {
            // Navigate to terms of service screen
          },
        ),
      ],
    );
  }
}
