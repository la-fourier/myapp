import 'package:flutter/material.dart';

enum ActionType {
  create,
  read,
  update,
  delete,
  navigate,
  function,
}

enum ActionCategory {
  core,
  calendar,
  planner,
  finances,
  map,
  contacts,
  settings,
}

class AppAction {
  final String id;
  final String name;
  final String pluginId;
  final ActionType type;
  final ActionCategory category;
  final IconData? icon;
  final VoidCallback onExecute;

  const AppAction({
    required this.id,
    required this.name,
    required this.pluginId,
    required this.type,
    required this.category,
    this.icon,
    required this.onExecute,
  });
}
