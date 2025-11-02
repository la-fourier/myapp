import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  final ScrollController? scrollController;
  const SettingsView({super.key, this.scrollController});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // TODO: This is a local state for demonstration. For a real app,
  // this should be managed by a proper state management solution.
  bool _toastNotificationsEnabled = true;

  void _showLanguageToast(String language) {
    Fluttertoast.showToast(msg: "Language set to $language (not implemented)");
    Navigator.of(context).pop();
  }

  void _showInfoDialog(String title, String content) {
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
    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        controller: widget.scrollController,
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
                  Tab(text: 'Advanced'),
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
            _buildAdvancedSettings(context),
            _buildAboutSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text('Theme'),
          trailing: DropdownButton<AppTheme>(
            value: themeProvider.currentTheme,
            onChanged: (AppTheme? newValue) {
              if (newValue != null) {
                themeProvider.setTheme(newValue);
              }
            },
            items: AppTheme.values.map((AppTheme theme) {
              return DropdownMenuItem<AppTheme>(
                value: theme,
                child: Text(theme.toString().split('.').last),
              );
            }).toList(),
          ),
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (value) {
            themeProvider.toggleThemeMode();
          },
          secondary: const Icon(Icons.dark_mode),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: const Text('English'), // This is static, would need a provider to be dynamic
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
                        ListTile(
                          title: const Text('English'),
                          onTap: () => _showLanguageToast('English'),
                        ),
                        ListTile(
                          title: const Text('German'),
                          onTap: () => _showLanguageToast('German'),
                        ),
                        ListTile(
                          title: const Text('Spanish'),
                          onTap: () => _showLanguageToast('Spanish'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSettings() {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Enable Toast Notifications'),
          value: _toastNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _toastNotificationsEnabled = value;
            });
            Fluttertoast.showToast(msg: "Toast notifications are now ${value ? 'enabled' : 'disabled'}");
          },
          secondary: const Icon(Icons.message),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings(BuildContext context) {
    return ListView(
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SwitchListTile(
              title: const Text('Show Advanced Query Field'),
              subtitle: const Text('Display a text field for filtering data in the dashboard.'),
              value: themeProvider.showQueryField,
              onChanged: (value) {
                themeProvider.toggleShowQueryField();
              },
              secondary: const Icon(Icons.code),
            );
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
          onTap: () => _showInfoDialog('About Orgaa', 'Version 1.0.0\n\nThis is a sample application.'),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () => _showInfoDialog('Privacy Policy', 'This is a placeholder for the privacy policy.'),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms of Service'),
          onTap: () => _showInfoDialog('Terms of Service', 'This is a placeholder for the terms of service.'),
        ),
      ],
    );
  }
}