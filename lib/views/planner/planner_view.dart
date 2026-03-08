import 'package:flutter/material.dart';
import 'package:myapp/views/habits/habits_view.dart';
import 'package:myapp/views/tasks/tasks_view.dart';
import 'package:myapp/l10n/app_localizations.dart';

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.repeat), text: AppLocalizations.of(context)?.habits ?? 'Habits'),
              Tab(icon: const Icon(Icons.check_circle_outline), text: AppLocalizations.of(context)?.planner ?? 'Tasks & Projects'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                const HabitsView(),
                const TasksView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
