import 'package:flutter/material.dart';

class LockScreenView extends StatelessWidget {
  const LockScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ['Familie', 'Freunde', 'Beziehung'];

    return Scaffold(
      appBar: AppBar(title: const Text('Sperrbildschirm Widget')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category),
            onTap: () {
              // ignore: avoid_print
              print('Selected: $category');
            },
          );
        },
      ),
    );
  }
}
