import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/theme_provider.dart';

class BorderRadiusSettingsView extends StatelessWidget {
  const BorderRadiusSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView(
      children: [
        RadioListTile<AppBorderRadius>(
          title: const Text('Rounded'),
          value: AppBorderRadius.rounded,
          groupValue: themeProvider.borderRadius,
          onChanged: (AppBorderRadius? value) {
            if (value != null) {
              themeProvider.setBorderRadius(value);
            }
          },
        ),
        RadioListTile<AppBorderRadius>(
          title: const Text('Squared'),
          value: AppBorderRadius.squared,
          groupValue: themeProvider.borderRadius,
          onChanged: (AppBorderRadius? value) {
            if (value != null) {
              themeProvider.setBorderRadius(value);
            }
          },
        ),
      ],
    );
  }
}
