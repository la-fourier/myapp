import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/services/toast_service.dart';
import 'package:myapp/l10n/app_localizations.dart';

class AppearanceSettingsView extends StatelessWidget {
  const AppearanceSettingsView({super.key});

  void _showLanguageToast(BuildContext context, String language) {
    AppToast.info(context, 'Language set to $language (not implemented)');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListView(
      primary: false,
      children: [
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: Text(AppLocalizations.of(context)?.theme ?? 'Theme'),
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
          title: Text(AppLocalizations.of(context)?.darkMode ?? 'Dark Mode'),
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (value) {
            themeProvider.toggleThemeMode();
          },
          secondary: const Icon(Icons.dark_mode),
        ),
        Consumer<AppState>(
          builder: (context, appState, child) {
            String localeName(Locale loc) {
              switch (loc.languageCode) {
                case 'en': return 'English';
                case 'de': return 'German';
                case 'es': return 'Spanish';
                default: return 'English';
              }
            }
            
            return ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppLocalizations.of(context)?.language ?? 'Language'),
              trailing: DropdownButton<Locale>(
                value: appState.currentLocale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    appState.setLocale(newLocale);
                  }
                },
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('de'), child: Text('German')),
                  DropdownMenuItem(value: Locale('es'), child: Text('Spanish')),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
