import 'package:flutter/material.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  final ScrollController? scrollController;
  const SettingsView({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: true,
              automaticallyImplyLeading: false, // No back button
              title: const Text('Settings'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Appearance'),
                  Tab(text: 'Notifications'),
                  Tab(text: 'About'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _buildAppearanceSettings(context),
            _buildNotificationsSettings(),
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
