import 'package:flutter/material.dart';
import 'package:myapp/services/plugin_service.dart';
import 'package:provider/provider.dart';

class PluginsSettingsView extends StatelessWidget {
  const PluginsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final pluginService = context.watch<PluginService>();
    final plugins = pluginService.getAvailablePlugins();

    return ListView.builder(
      primary: false,
      padding: const EdgeInsets.all(16),
      itemCount: plugins.length,
      itemBuilder: (context, index) {
        final plugin = plugins[index];
        final isActive = pluginService.isPluginActive(plugin);

        return SwitchListTile(
          title: Text(_getPluginName(plugin)),
          subtitle: Text('Plugin ID: ${plugin.id}'),
          value: isActive,
          onChanged: (value) {
            pluginService.togglePlugin(plugin);
          },
        );
      },
    );
  }

  String _getPluginName(PluginType type) {
    switch (type) {
      case PluginType.calendar: return 'Kalender';
      case PluginType.planner: return 'Planer';
      case PluginType.finances: return 'Finanzen';
      case PluginType.map: return 'Karte';
      case PluginType.contacts: return 'Kontakte';
    }
  }
}
