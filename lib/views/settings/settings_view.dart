import 'package:flutter/material.dart';
import 'package:myapp/views/settings/appearance_settings_view.dart';
import 'package:myapp/views/settings/notification_settings_view.dart';
import 'package:myapp/views/settings/advanced_settings_view.dart';
import 'package:myapp/views/settings/about_settings_view.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/views/settings/keybindings_settings_view.dart';
import 'package:myapp/l10n/app_localizations.dart';

class SettingsView extends StatefulWidget {
  final ScrollController? scrollController;
  const SettingsView({super.key, this.scrollController});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 5,
        child: NestedScrollView(
          controller: widget.scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                floating: true,
                automaticallyImplyLeading: false, // No back button
                title: Text(AppLocalizations.of(context)?.settings ?? 'Settings'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
                bottom: TabBar(
                  splashBorderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  isScrollable: true,
                  tabs: [
                    Tab(text: AppLocalizations.of(context)?.appearance ?? 'Appearance'),
                    Tab(text: AppLocalizations.of(context)?.keybindings ?? 'Keybindings'),
                    Tab(text: AppLocalizations.of(context)?.notifications ?? 'Notifications'),
                    Tab(text: AppLocalizations.of(context)?.advanced ?? 'Advanced'),
                    Tab(text: AppLocalizations.of(context)?.about ?? 'About'),
                  ],
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              AppearanceSettingsView(),
              KeybindingsSettingsView(),
              NotificationSettingsView(),
              AdvancedSettingsView(),
              AboutSettingsView(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Provider.of<AppState>(context, listen: false).saveSettings();
          Fluttertoast.showToast(msg: AppLocalizations.of(context)?.saveSettings ?? "Settings saved.");
        },
        icon: const Icon(Icons.save),
        label: Text(AppLocalizations.of(context)?.save ?? 'Save'),
      ),
    );
  }
}
