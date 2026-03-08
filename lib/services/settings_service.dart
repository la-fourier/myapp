import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class SettingsService with ChangeNotifier {
  Map<String, dynamic> _settings = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    await loadSettings();
  }

  Future<File?> get _settingsFile async {
    if (kIsWeb) return null;
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/settings.json');
    } catch (e) {
      debugPrint('path_provider not available: $e');
      return null;
    }
  }

  Future<void> loadSettings() async {
    try {
      if (kIsWeb) {
        // Future: implement LocalStorage persistence
        _settings = _defaultSettings();
      } else {
        final file = await _settingsFile;
        if (file != null && await file.exists()) {
          final content = await file.readAsString();
          final decoded = json.decode(content);
          if (decoded is Map) {
            _settings = Map<String, dynamic>.from(decoded);
          } else {
            _settings = _defaultSettings();
          }
        } else {
          _settings = _defaultSettings();
        }
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _settings = _defaultSettings();
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> saveSettings() async {
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null) {
        await file.writeAsString(json.encode(_settings));
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Map<String, dynamic> _defaultSettings() {
    return {
      'plugins': {
        'calendar': true,
        'planner': true,
        'finances': true,
        'map': true,
        'contacts': true,
      },
      'keybindings': {
        'open_dashboard': 'ctrl+d',
        'open_calendar': 'ctrl+k',
        'open_planner': 'ctrl+p',
        'open_contacts': 'ctrl+c',
        'open_map': 'ctrl+m',
        'open_finances': 'ctrl+f',
        'open_settings': 'ctrl+s',
        'calendar_add_appointment': 'ctrl+n',
      },
      'themeMode': 'system',
      'language': 'de',
    };
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settings[key] ?? defaultValue;
  }

  Future<void> updateSetting(String key, dynamic value) async {
    _settings[key] = value;
    await saveSettings();
    notifyListeners();
  }

  // Specialized helpers
  Map<String, bool> getActivePlugins() {
    final pluginsData = _settings['plugins'];
    if (pluginsData is Map) {
      return Map<String, bool>.from(pluginsData.map((key, value) => MapEntry(key.toString(), value as bool)));
    }
    return {};
  }

  Future<void> updatePluginStatus(String pluginId, bool isActive) async {
    final plugins = Map<String, dynamic>.from(_settings['plugins'] ?? {});
    plugins[pluginId] = isActive;
    _settings['plugins'] = plugins;
    await saveSettings();
    notifyListeners();
  }
}
