import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:myapp/views/finance/finance_view.dart';
import 'package:myapp/views/user/account_view.dart';
import 'package:myapp/views/calendar/calendar_view.dart';
import 'package:myapp/views/calendar/day_view.dart';
import 'package:myapp/views/main/dashboard_view.dart';
import 'package:myapp/views/settings/settings_view.dart';
import 'package:myapp/views/main/stats_view.dart';
import 'package:myapp/views/main/today_view.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/loading_service.dart';
import 'package:myapp/backend_integrations/google.dart';
import 'package:myapp/backend_integrations/github.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/widgets/play_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String syncService = 'google'; // or 'github' or 'none'

  void _handleDaySelected(DateTime day) {
    _showAsModalSheet((scrollController) => DayView(
          selectedDay: day,
          onBack: () => Navigator.of(context).pop(),
          scrollController: scrollController,
        ));
  }

  void _showAsModalSheet(Widget Function(ScrollController) builder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.3),
      barrierColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (BuildContext context, ScrollController scrollController) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 40, left: 16, right: 16),
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
          ),
        );
      },
    );
  }

  late final List<Widget> _mainViews;

  @override
  void initState() {
    super.initState();
    _mainViews = <Widget>[
      DashboardView(showAsModalSheet: _showAsModalSheet),
      CalendarView(onDaySelected: _handleDaySelected),
      const TodayView(),
      const StatsView(),
      const FinanceView(),
    ];
  }

  static const List<String> _widgetTitles = <String>[
    'Dashboard',
    'Calendar',
    'Today',
    'Stats',
    'Finance',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _syncData() async {
    final loadingService = LoadingService();
    final appState = Provider.of<AppState>(context, listen: false);
    final appData = {
      'user': appState.loggedInUser!.person.fullName, // Just an example of data to sync
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
      Fluttertoast.showToast(
        msg: "Sync successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Sync failed: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      loadingService.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AppState>(context, listen: false).logout();
            },
            tooltip: 'Logout',
          ),
          title: Text(_widgetTitles[_selectedIndex]),
          actions: [
            if (!isMobile)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 350,
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
              onPressed: () => _showAsModalSheet((controller) => SettingsView(scrollController: controller)),
              tooltip: 'Settings',
            ),
            IconButton(
              icon: const Icon(Icons.account_box_rounded),
              onPressed: () => _showAsModalSheet((controller) => AccountView(scrollController: controller)),
              tooltip: 'Account',
            ),
          ],
        ),
        body: isMobile
            ? _mainViews.elementAt(_selectedIndex)
            : Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onItemTapped,
                    labelType: NavigationRailLabelType.all,
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.calendar_today_outlined),
                        selectedIcon: Icon(Icons.calendar_today),
                        label: Text('Calendar'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.today_outlined),
                        selectedIcon: Icon(Icons.today),
                        label: Text('Today'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.bar_chart_outlined),
                        selectedIcon: Icon(Icons.bar_chart),
                        label: Text('Stats'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.attach_money),
                        selectedIcon: Icon(Icons.money),
                        label: Text('Finance'),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: _mainViews.elementAt(_selectedIndex)),
                ],
              ),
        floatingActionButton: isMobile
            ? const PlayBar(viewType: PlayBarViewType.compact)
            : null,
        bottomNavigationBar: isMobile
            ? NavigationBar(
                onDestinationSelected: _onItemTapped,
                selectedIndex: _selectedIndex,
                destinations: const <Widget>[
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today),
                    label: 'Calendar',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.today_outlined),
                    selectedIcon: Icon(Icons.today),
                    label: 'Today',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: 'Stats',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.attach_money),
                    selectedIcon: Icon(Icons.money),
                    label: 'Finance',
                  ),
                ],
              )
            : const SizedBox.shrink(),
      );
    });
  }
}
