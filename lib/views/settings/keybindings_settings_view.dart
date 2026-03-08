import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/services/settings_service.dart';
import 'package:myapp/services/action_registry.dart';
import 'package:myapp/models/app_action.dart';

class KeybindingsSettingsView extends StatelessWidget {
  const KeybindingsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final registry = context.watch<ActionRegistry>();
    final settings = context.watch<SettingsService>();
    final bindings = Map<String, dynamic>.from(settings.getSetting('keybindings', defaultValue: {}));

    final actions = registry.actions;
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Group actions by category
    final Map<ActionCategory, List<AppAction>> groupedActions = {};
    for (final action in actions) {
      groupedActions.putIfAbsent(action.category, () => []).add(action);
    }

    return ListView(
      primary: false,
      padding: const EdgeInsets.all(16.0),
      children: groupedActions.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Text(
                _getCategoryName(entry.key, loc),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...entry.value.map((action) {
              final shortcut = bindings[action.id] ?? '';
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                margin: const EdgeInsets.only(bottom: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(action.icon ?? Icons.keyboard, size: 20),
                  title: Text(action.name),
                  subtitle: Text(
                    shortcut.isEmpty 
                      ? (loc?.advanced ?? 'None') 
                      : shortcut.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: shortcut.isEmpty ? Colors.grey : theme.colorScheme.secondary,
                    ),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => _showRebindDialog(context, action, settings),
                    child: Text(loc?.edit ?? 'Edit'),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  String _getCategoryName(ActionCategory category, AppLocalizations? loc) {
    switch (category) {
      case ActionCategory.core: return loc?.dashboard ?? 'Core';
      case ActionCategory.calendar: return loc?.calendar ?? 'Calendar';
      case ActionCategory.planner: return loc?.planner ?? 'Planner';
      case ActionCategory.finances: return loc?.finances ?? 'Finances';
      case ActionCategory.map: return loc?.map ?? 'Map';
      case ActionCategory.contacts: return loc?.contacts ?? 'Contacts';
      case ActionCategory.settings: return loc?.settings ?? 'Settings';
    }
  }

  void _showRebindDialog(BuildContext context, AppAction action, SettingsService settings) {
    String newShortcut = '';
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(action.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc?.advanced ?? 'Combination:'),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. ctrl+s, alt+p, n',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.keyboard),
                ),
                onChanged: (value) => newShortcut = value,
              ),
              const SizedBox(height: 8),
              Text(
                'Use lowercase (ctrl, alt, shift + key)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final bindings = Map<String, dynamic>.from(settings.getSetting('keybindings', defaultValue: {}));
                bindings[action.id] = newShortcut;
                await settings.updateSetting('keybindings', bindings);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(loc?.save ?? 'Save'),
            ),
          ],
        );
      },
    );
  }
}
