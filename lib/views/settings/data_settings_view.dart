import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/settings_service.dart';
import 'package:myapp/services/storage_service.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/services/export_service.dart';
import 'package:myapp/services/loading_service.dart';
import 'package:myapp/services/toast_service.dart';

class DataSettingsView extends StatefulWidget {
  const DataSettingsView({super.key});

  @override
  State<DataSettingsView> createState() => _DataSettingsViewState();
}

class _DataSettingsViewState extends State<DataSettingsView> {
  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final appState = Provider.of<AppState>(context, listen: false);
    final storageType = settingsService.getStorageType();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Storage Provider',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            RadioListTile<StorageType>(
              title: const Text('Local Database (Sembast)'),
              subtitle: const Text('Fast, local, and robust. Recommended for most users.'),
              value: StorageType.sembast,
              groupValue: storageType,
              onChanged: (StorageType? value) {
                if (value != null) {
                  settingsService.updateSetting('storageType', value.name);
                  _showRestartDialog(context);
                }
              },
            ),
            RadioListTile<StorageType>(
              title: const Text('Legacy File Storage'),
              subtitle: const Text('Older file-based storage. Use for compatibility if needed.'),
              value: StorageType.legacy,
              groupValue: storageType,
              onChanged: (StorageType? value) {
                if (value != null) {
                  settingsService.updateSetting('storageType', value.name);
                  _showRestartDialog(context);
                }
              },
            ),
            RadioListTile<StorageType>(
              title: const Text('GitHub'),
              subtitle: const Text('Store your data in a private GitHub repository. (Coming soon...)'),
              value: StorageType.github,
              groupValue: storageType,
              onChanged: null, // Disabled for now
            ),
            const Divider(height: 32),
            Text(
              'Export Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Download all your data as a single file.'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showExportDialog(context, appState),
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Restart Required'),
          content: Text('The application needs to be restarted for the storage provider change to take effect.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Export Format'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('CSV'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportData(context, appState, 'csv');
                },
              ),
              ListTile(
                title: const Text('JSON'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportData(context, appState, 'json');
                },
              ),
              ListTile(
                title: const Text('TXT'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportData(context, appState, 'txt');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportData(BuildContext context, AppState appState, String format) async {
    final loadingService = LoadingService();
    loadingService.show();
    try {
      final exportService = ExportService();
      await exportService.exportData(appState, format);
      if (context.mounted) AppToast.success(context, 'Data exported successfully as $format');
    } catch (e) {
      if (context.mounted) AppToast.error(context, 'Failed to export data: ${e.toString()}');
    } finally {
      loadingService.hide();
    }
  }
}
