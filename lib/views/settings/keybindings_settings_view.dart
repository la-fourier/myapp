import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:flutter/services.dart';

class KeybindingsSettingsView extends StatelessWidget {
  const KeybindingsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final bindings = appState.keybindings;
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: bindings.entries.map((entry) {
            final actionName = entry.key;
            final activator = entry.value;

            String keyLabel = '';
            if (activator.control) keyLabel += 'Ctrl + ';
            if (activator.shift) keyLabel += 'Shift + ';
            if (activator.alt) keyLabel += 'Alt + ';
            
            // Extrac the key name manually (basic approach)
            String rawKey = activator.trigger.keyLabel;
            keyLabel += rawKey;

            return ListTile(
              title: Text(actionName.replaceAll('_', ' ').toUpperCase()),
              subtitle: Text(keyLabel),
              trailing: ElevatedButton(
                onPressed: () {
                  // In a full implementation, this opens a dialog listening for raw keyboard events to rebind.
                  // For now, we mock the rebind for demonstration.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pressing new keys to rebind is a complex feature. Mocking UI for now.')),
                  );
                },
                child: const Text('Rebind'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
