import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/theme_provider.dart';

class AdvancedSettingsView extends StatelessWidget {
  const AdvancedSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SwitchListTile(
              title: const Text('Show Advanced Query Field'),
              subtitle: const Text(
                'Display a text field for filtering data in the dashboard.',
              ),
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
}
