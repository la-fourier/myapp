import 'package:flutter/material.dart';

class DataView extends StatelessWidget {
  const DataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data'),
      ),
      body: const Center(
        child: Text('Data View'),
      ),
    );
  }
}
