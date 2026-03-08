import 'package:flutter/foundation.dart';
import 'package:myapp/services/settings_service.dart';

enum PluginType {
  calendar,
  planner,
  finances,
  map,
  contacts;

  String get id => name;
}

class PluginService with ChangeNotifier {
  final SettingsService _settingsService;
  Map<String, bool> _activePlugins = {};

  PluginService(this._settingsService) {
    _settingsService.addListener(_updateFromSettings);
    _updateFromSettings();
  }

  void _updateFromSettings() {
    _activePlugins = _settingsService.getActivePlugins();
    notifyListeners();
  }

  bool isPluginActive(PluginType type) {
    return _activePlugins[type.id] ?? true;
  }

  Future<void> togglePlugin(PluginType type) async {
    bool currentStatus = isPluginActive(type);
    await _settingsService.updatePluginStatus(type.id, !currentStatus);
  }

  List<PluginType> getAvailablePlugins() {
    return PluginType.values;
  }
}
