import 'package:flutter/foundation.dart';
import 'package:myapp/models/app_action.dart';

class ActionRegistry with ChangeNotifier {
  final List<AppAction> _actions = [];

  List<AppAction> get actions => List.unmodifiable(_actions);

  void registerAction(AppAction action) {
    _actions.add(action);
    notifyListeners();
  }

  void registerAll(List<AppAction> actions) {
    _actions.addAll(actions);
    notifyListeners();
  }

  AppAction? getAction(String id) {
    try {
      return _actions.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AppAction> getActionsByPlugin(String pluginId) {
    return _actions.where((a) => a.pluginId == pluginId).toList();
  }
}
