import 'package:flutter/material.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.palette), text: 'Appearance'),
              Tab(icon: Icon(Icons.cloud), text: 'Integrations'),
              Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
              Tab(icon: Icon(Icons.info), text: 'About'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: TabBarView(
              children: [
                _buildAppearanceSettings(context),
                _buildIntegrationSettions(context),
                _buildNotificationsSettings(),
                _buildAboutSettings(),
              ],
            ),
          ),
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
        Consumer<ThemeProvider>(builder: (context, value, child) {
          return ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: const Text('English'),
          onTap: () {
            // Show language selection dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select Language'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        GestureDetector(
                          child: const Text('English'),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          child: const Text('German'),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          child: const Text('Spanish'),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
        })
      ],
    );
  }

  Widget _buildIntegrationSettions(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud),
          title: const Text('Cloud Sync Service'),
          subtitle: const Text('Google Drive'),
          onTap: () {
            // Show cloud sync service selection dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('User'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter username',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.email),
                            const Text('Email: '),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter email',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.grain),
          title: const Text('Github Sync Service'),
          // subtitle: const Text('2024'),
          onTap: () {
            // Show sync details
          },
        ),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Sync Now'),
          onTap: () {
            // Trigger sync action
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSettings() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.message),
          title: const Text('Enable Toast Notifications'),
          trailing: Switch(
            value: true,
            onChanged: (value) {},
          ),
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
