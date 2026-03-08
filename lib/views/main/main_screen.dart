import 'dart:ui';
// Trigger hot reload for localizations updates.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/dialogs/appointment_editor_dialog.dart';
import 'package:myapp/services/toast_service.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/views/finance/finance_view.dart';
import 'package:myapp/views/user/account_view.dart';
import 'package:myapp/views/calendar/calendar_view.dart';
import 'package:myapp/views/calendar/day_view.dart';
import 'package:myapp/views/main/dashboard_view.dart';
import 'package:myapp/views/settings/settings_view.dart';
import 'package:myapp/views/main/stats_view.dart';
import 'package:myapp/views/main/today_view.dart';
import 'package:myapp/views/contacts/contacts_view.dart';
import 'package:myapp/views/planner/planner_view.dart';
import 'package:myapp/views/map/map_view.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/loading_service.dart';
import 'package:myapp/backend_integrations/google.dart';
import 'package:myapp/backend_integrations/github.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/widgets/play_bar.dart';
import 'package:myapp/services/plugin_service.dart';
import 'package:myapp/services/action_registry.dart';
import 'package:myapp/models/app_action.dart';
import 'package:myapp/services/settings_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String syncService = 'google'; // or 'github' or 'none'

  void _handleDaySelected(DateTime day) {
    _showAsModalSheet(
      (scrollController) => DayView(
        selectedDay: day,
        onBack: () => Navigator.of(context).pop(),
        scrollController: scrollController,
      ),
    );
  }

  void _showAsModalSheet(Widget Function(ScrollController) builder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.3),
      // barrierDismissible: true, // Allow dismissing by tapping outside
      elevation: 0,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 20,
                    bottom: 40,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: builder(scrollController),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerActions();
    });
  }

  void _registerActions() {
    final registry = context.read<ActionRegistry>();
    final loc = AppLocalizations.of(context);

    registry.registerAll([
      AppAction(
        id: 'open_dashboard',
        name: loc?.dashboard ?? 'Dashboard öffnen',
        pluginId: 'core',
        type: ActionType.navigate,
        category: ActionCategory.core,
        icon: Icons.dashboard,
        onExecute: () => _navigateToPlugin('dashboard'),
      ),
      AppAction(
        id: 'open_calendar',
        name: loc?.calendar ?? 'Kalender öffnen',
        pluginId: 'calendar',
        type: ActionType.navigate,
        category: ActionCategory.calendar,
        icon: Icons.calendar_today,
        onExecute: () => _navigateToPlugin('calendar'),
      ),
      AppAction(
        id: 'open_planner',
        name: loc?.planner ?? 'Planer öffnen',
        pluginId: 'planner',
        type: ActionType.navigate,
        category: ActionCategory.planner,
        icon: Icons.event_note,
        onExecute: () => _navigateToPlugin('planner'),
      ),
      AppAction(
        id: 'open_contacts',
        name: loc?.contacts ?? 'Kontakte öffnen',
        pluginId: 'contacts',
        type: ActionType.navigate,
        category: ActionCategory.contacts,
        icon: Icons.people,
        onExecute: () => _navigateToPlugin('contacts'),
      ),
      AppAction(
        id: 'open_map',
        name: loc?.map ?? 'Karte öffnen',
        pluginId: 'map',
        type: ActionType.navigate,
        category: ActionCategory.map,
        icon: Icons.map,
        onExecute: () => _navigateToPlugin('map'),
      ),
      AppAction(
        id: 'open_finances',
        name: loc?.finances ?? 'Finanzen öffnen',
        pluginId: 'finances',
        type: ActionType.navigate,
        category: ActionCategory.finances,
        icon: Icons.attach_money,
        onExecute: () => _navigateToPlugin('finances'),
      ),
      AppAction(
        id: 'open_settings',
        name: loc?.settings ?? 'Einstellungen öffnen',
        pluginId: 'core',
        type: ActionType.navigate,
        category: ActionCategory.settings,
        icon: Icons.settings,
        onExecute: () => _showAsModalSheet((c) => SettingsView(scrollController: c)),
      ),
      // CRUD Actions
      AppAction(
        id: 'calendar_add_appointment',
        name: 'Termin hinzufügen',
        pluginId: 'calendar',
        type: ActionType.create,
        category: ActionCategory.calendar,
        icon: Icons.add_task,
        onExecute: () {
          showDialog(
            context: context,
            builder: (context) => AppointmentEditorDialog(onSave: (a) {
              Provider.of<AppState>(context, listen: false).addItem(a);
            }),
          );
        },
      ),
      AppAction(
        id: 'planner_add_habit',
        name: 'Gewohnheit hinzufügen',
        pluginId: 'planner',
        type: ActionType.create,
        category: ActionCategory.planner,
        icon: Icons.repeat,
        onExecute: () {
          AppToast.info(context, 'Habit Editor (Coming soon)');
        },
      ),
      AppAction(
        id: 'planner_add_task',
        name: 'Aufgabe hinzufügen',
        pluginId: 'planner',
        type: ActionType.create,
        category: ActionCategory.planner,
        icon: Icons.check_circle_outline,
        onExecute: () {
          AppToast.info(context, 'Task Editor (Coming soon)');
        },
      ),
      AppAction(
        id: 'finance_add_bill',
        name: 'Rechnung hinzufügen',
        pluginId: 'finances',
        type: ActionType.create,
        category: ActionCategory.finances,
        icon: Icons.receipt_long,
        onExecute: () {
          AppToast.info(context, 'Finance Editor (Coming soon)');
        },
      ),
      AppAction(
        id: 'contacts_add_person',
        name: 'Kontakt hinzufügen',
        pluginId: 'contacts',
        type: ActionType.create,
        category: ActionCategory.contacts,
        icon: Icons.person_add,
        onExecute: () {
          AppToast.info(context, 'Contact Editor (Coming soon)');
        },
      ),
      AppAction(
        id: 'map_add_location',
        name: 'Ort hinzufügen',
        pluginId: 'map',
        type: ActionType.create,
        category: ActionCategory.map,
        icon: Icons.add_location_alt,
        onExecute: () {
          AppToast.info(context, 'Long-press map to add locations');
        },
      ),
    ]);
  }

  void _navigateToPlugin(String pluginId) {
    final pluginService = context.read<PluginService>();
    final loc = AppLocalizations.of(context);
    final activeItems = _getNavItems(pluginService, loc);
    final index = activeItems.indexWhere((item) => item.pluginId == pluginId);
    if (index != -1) {
      _onItemTapped(index);
    }
  }

  List<_NavItem> _getNavItems(PluginService pluginService, AppLocalizations? loc) {
    final items = [
      _NavItem(
        pluginId: 'dashboard',
        title: loc?.dashboard ?? 'Dashboard',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        view: DashboardView(showAsModalSheet: _showAsModalSheet),
      ),
      if (pluginService.isPluginActive(PluginType.calendar))
        _NavItem(
          pluginId: 'calendar',
          title: loc?.calendar ?? 'Calendar',
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today,
          view: CalendarView(onDaySelected: _handleDaySelected),
        ),
      if (pluginService.isPluginActive(PluginType.planner))
        _NavItem(
          pluginId: 'planner',
          title: loc?.planner ?? 'Planner',
          icon: Icons.event_note,
          selectedIcon: Icons.event_note_rounded,
          view: const PlannerView(),
        ),
      if (pluginService.isPluginActive(PluginType.contacts))
        _NavItem(
          pluginId: 'contacts',
          title: loc?.contacts ?? 'Contacts',
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          view: const ContactsView(),
        ),
      _NavItem(
        pluginId: 'today',
        title: loc?.today ?? 'Today',
        icon: Icons.today_outlined,
        selectedIcon: Icons.today,
        view: const TodayView(),
      ),
      _NavItem(
        pluginId: 'stats',
        title: loc?.stats ?? 'Stats',
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        view: const StatsView(),
      ),
      if (pluginService.isPluginActive(PluginType.map))
        _NavItem(
          pluginId: 'map',
          title: loc?.map ?? 'Map',
          icon: Icons.map_outlined,
          selectedIcon: Icons.map,
          view: const MapView(),
        ),
      if (pluginService.isPluginActive(PluginType.finances))
        _NavItem(
          pluginId: 'finances',
          title: loc?.finances ?? 'Finance',
          icon: Icons.attach_money,
          selectedIcon: Icons.money,
          view: const FinanceView(),
        ),
    ];
    return items;
  }

  String _getWidgetTitle(BuildContext context, int index) {
    final pluginService = context.read<PluginService>();
    final loc = AppLocalizations.of(context);
    final items = _getNavItems(pluginService, loc);
    if (index >= 0 && index < items.length) {
      return items[index].title;
    }
    return '';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _syncData() async {
    final loadingService = LoadingService();
    final appState = Provider.of<AppState>(context, listen: false);
    final appData = {
      'user': appState
          .loggedInUser!
          .person
          .fullName, // Just an example of data to sync
    };

    loadingService.show();
    try {
      final googleService = GoogleDriveService();
      final githubService = GitHubService();

      if (syncService == 'google') {
        await googleService.connect();
        await googleService.uploadJson('app_data.json', appData);
      } else if (syncService == 'github') {
        await githubService.connect();
        await githubService.uploadJson('app_data.json', appData);
      }
      if (mounted) AppToast.success(context, 'Sync successful');
    } catch (e) {
      if (mounted) AppToast.error(context, 'Sync failed: ${e.toString()}');
    } finally {
      loadingService.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        final pluginService = context.watch<PluginService>();
        final loc = AppLocalizations.of(context);
        final navItems = _getNavItems(pluginService, loc);
        final settings = context.watch<SettingsService>();
        final registry = context.watch<ActionRegistry>();
        
        // Map from shortcut string (e.g., 'ctrl+s') to Intent
        final Map<ShortcutActivator, Intent> shortcuts = {};
        final Map<Type, Action<Intent>> actions = {};

        final userKeybindings = Map<String, dynamic>.from(settings.getSetting('keybindings', defaultValue: {}));

        for (final entry in userKeybindings.entries) {
          final actionId = entry.key;
          final shortcutStr = entry.value as String;
          final appAction = registry.getAction(actionId);
          
          if (appAction != null) {
            final activator = _parseShortcut(shortcutStr);
            if (activator != null) {
              final intent = _AppActionIntent(appAction);
              shortcuts[activator] = intent;
              actions[_AppActionIntent] = _AppActionHandler();
            }
          }
        }

        return Shortcuts(
          shortcuts: shortcuts,
          child: Actions(
            actions: actions,
            child: Focus(
              autofocus: true,
              child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Provider.of<AppState>(context, listen: false).logout();
                  },
                  tooltip: 'Logout',
                ),
            title: Text(_getWidgetTitle(context, _selectedIndex)),
            actions: [
              if (!isMobile)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 250,
                      child: PlayBar(viewType: PlayBarViewType.full),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: _syncData,
                tooltip: 'Sync',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showAsModalSheet(
                  (controller) => SettingsView(scrollController: controller),
                ),
                tooltip: 'Settings',
              ),
              IconButton(
                icon: const Icon(Icons.account_box_rounded),
                onPressed: () => _showAsModalSheet(
                  (controller) => AccountView(scrollController: controller),
                ),
                tooltip: 'Account',
              ),
            ],
          ),
          body: isMobile
              ? navItems[_selectedIndex % navItems.length].view
              : Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex % navItems.length,
                      onDestinationSelected: _onItemTapped,
                      labelType: NavigationRailLabelType.all,
                      destinations: navItems.map((item) {
                        return NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.title),
                        );
                      }).toList(),
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: navItems[_selectedIndex % navItems.length].view),
                  ],
                ),
          floatingActionButton: isMobile
              ? const PlayBar(viewType: PlayBarViewType.compact)
              : null,
          bottomNavigationBar: isMobile
              ? NavigationBar(
                  onDestinationSelected: _onItemTapped,
                  selectedIndex: _selectedIndex,
                  destinations: navItems.take(5).map((item) {
                    return NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.title,
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
  ShortcutActivator? _parseShortcut(String shortcut) {
    if (shortcut.isEmpty) return null;
    final parts = shortcut.toLowerCase().split('+');
    
    LogicalKeyboardKey? key;
    bool control = false;
    bool alt = false;
    bool shift = false;

    for (final part in parts) {
      final p = part.trim();
      if (p == 'ctrl' || p == 'control') {
        control = true;
      } else if (p == 'alt') {
        alt = true;
      } else if (p == 'shift') {
        shift = true;
      } else {
        // Map common keys
        if (p.length == 1) {
          // It's likely a letter key
          final char = p.toUpperCase();
          // We can use the LogicalKeyboardKey.keyA..keyZ pattern
          // This is a bit manual but safer. 
          // For simplicity, we'll map the most likely ones.
          switch (char) {
            case 'A': key = LogicalKeyboardKey.keyA; break;
            case 'B': key = LogicalKeyboardKey.keyB; break;
            case 'C': key = LogicalKeyboardKey.keyC; break;
            case 'D': key = LogicalKeyboardKey.keyD; break;
            case 'E': key = LogicalKeyboardKey.keyE; break;
            case 'F': key = LogicalKeyboardKey.keyF; break;
            case 'G': key = LogicalKeyboardKey.keyG; break;
            case 'H': key = LogicalKeyboardKey.keyH; break;
            case 'I': key = LogicalKeyboardKey.keyI; break;
            case 'J': key = LogicalKeyboardKey.keyJ; break;
            case 'K': key = LogicalKeyboardKey.keyK; break;
            case 'L': key = LogicalKeyboardKey.keyL; break;
            case 'M': key = LogicalKeyboardKey.keyM; break;
            case 'N': key = LogicalKeyboardKey.keyN; break;
            case 'O': key = LogicalKeyboardKey.keyO; break;
            case 'P': key = LogicalKeyboardKey.keyP; break;
            case 'Q': key = LogicalKeyboardKey.keyQ; break;
            case 'R': key = LogicalKeyboardKey.keyR; break;
            case 'S': key = LogicalKeyboardKey.keyS; break;
            case 'T': key = LogicalKeyboardKey.keyT; break;
            case 'U': key = LogicalKeyboardKey.keyU; break;
            case 'V': key = LogicalKeyboardKey.keyV; break;
            case 'W': key = LogicalKeyboardKey.keyW; break;
            case 'X': key = LogicalKeyboardKey.keyX; break;
            case 'Y': key = LogicalKeyboardKey.keyY; break;
            case 'Z': key = LogicalKeyboardKey.keyZ; break;
          }
        } else {
          // Handle special keys
          switch (p) {
            case 'enter': key = LogicalKeyboardKey.enter; break;
            case 'space': key = LogicalKeyboardKey.space; break;
            case 'escape': key = LogicalKeyboardKey.escape; break;
            case 'tab': key = LogicalKeyboardKey.tab; break;
            case 'backspace': key = LogicalKeyboardKey.backspace; break;
            case 'delete': key = LogicalKeyboardKey.delete; break;
          }
        }
      }
    }

    if (key == null) return null;
    return SingleActivator(key, control: control, alt: alt, shift: shift);
  }
}

class _NavItem {
  final String pluginId;
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Widget view;

  _NavItem({
    required this.pluginId,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.view,
  });
}

class _AppActionIntent extends Intent {
  final AppAction action;
  const _AppActionIntent(this.action);
}

class _AppActionHandler extends Action<_AppActionIntent> {
  @override
  Object? invoke(_AppActionIntent intent) {
    intent.action.onExecute();
    return null;
  }
}
