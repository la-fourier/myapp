import 'package:flutter/material.dart';
import 'package:myapp/views/settings/appearance_settings_view.dart';
import 'package:myapp/views/settings/border_radius_settings_view.dart';
import 'package:myapp/views/settings/notification_settings_view.dart';
import 'package:myapp/views/settings/advanced_settings_view.dart';
import 'package:myapp/views/settings/about_settings_view.dart';

import 'package:myapp/views/settings/keybindings_settings_view.dart';

class SettingsView extends StatefulWidget {
  final ScrollController? scrollController;
  const SettingsView({super.key, this.scrollController});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: NestedScrollView(
        controller: widget.scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: true,
              automaticallyImplyLeading: false, // No back button
              title: const Text('Settings'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              bottom: const TabBar(
                splashBorderRadius: BorderRadius.all(Radius.circular(10.0)),
                isScrollable: true,
                tabs: [
                  Tab(text: 'Appearance'),
                  Tab(text: 'Borders'),
                  Tab(text: 'Keybindings'),
                  Tab(text: 'Notifications'),
                  Tab(text: 'Advanced'),
                  Tab(text: 'About'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            const AppearanceSettingsView(),
            const BorderRadiusSettingsView(),
            const KeybindingsSettingsView(),
            const NotificationSettingsView(),
            const AdvancedSettingsView(),
            const AboutSettingsView(),
          ],
        ),
      ),
    );
  }
}
