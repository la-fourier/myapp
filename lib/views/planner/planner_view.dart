import 'package:flutter/material.dart';
import 'package:myapp/views/habits/habits_view.dart';
import 'package:myapp/views/tasks/tasks_view.dart';

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.repeat), text: 'Habits'),
              Tab(icon: Icon(Icons.check_circle_outline), text: 'Tasks'),
            ],
          ),
          Expanded(
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
