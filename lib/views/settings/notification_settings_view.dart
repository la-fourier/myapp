import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/toast_service.dart';
import 'package:myapp/services/app_state.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      children: [
        Consumer<AppState>(
          builder: (context, appState, child) {
            return SwitchListTile(
              title: const Text('Enable Toast Notifications'),
              value: appState.toastNotificationsEnabled,
              onChanged: (value) {
                appState.setToastNotificationsEnabled(value);
                AppToast.info(
                  context,
                  "Toast notifications are now ${value ? 'enabled' : 'disabled'}",
                );
              },
              secondary: const Icon(Icons.message),
            );
          },
        ),
      ],
    );
  }
}
