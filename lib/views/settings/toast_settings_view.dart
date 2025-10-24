import 'package:flutter/material.dart';

class ToastSettingsView extends StatelessWidget {
  const ToastSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toast Settings'),
      ),
      body: const Center(
        child: Text('This is the Toast Settings page.'),
      ),
    );
  }
}
