import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/services/app_state.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Consumer<AppState>(
          builder: (context, appState, child) {
            return SwitchListTile(
              title: const Text('Enable Toast Notifications'),
              value: appState.toastNotificationsEnabled,
              onChanged: (value) {
                appState.setToastNotificationsEnabled(value);
                Fluttertoast.showToast(
                  msg: "Toast notifications are now ${value ? 'enabled' : 'disabled'}",
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
