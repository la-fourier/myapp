import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:myapp/views/settings/border_radius_settings_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppearanceSettingsView extends StatelessWidget {
  const AppearanceSettingsView({super.key});

  void _showLanguageToast(BuildContext context, String language) {
    Fluttertoast.showToast(msg: "Language set to $language (not implemented)");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
          leading: const Icon(Icons.rounded_corner),
          title: const Text('Border Radius'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BorderRadiusSettingsView(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: const Text('English'), 
          onTap: () {
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
                          onTap: () => _showLanguageToast(context, 'English'),
                        ),
                        ListTile(
                          title: const Text('German'),
                          onTap: () => _showLanguageToast(context, 'German'),
                        ),
                        ListTile(
                          title: const Text('Spanish'),
                          onTap: () => _showLanguageToast(context, 'Spanish'),
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
}
