import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/models/task_item.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/services/planner_algorithm_service.dart';
import 'package:myapp/views/habits/habits_view.dart';
import 'package:myapp/views/tasks/tasks_view.dart';
import 'package:myapp/l10n/app_localizations.dart';

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  tabs: [
                    Tab(icon: const Icon(Icons.repeat), text: loc?.habits ?? 'Habits'),
                    Tab(icon: const Icon(Icons.check_circle_outline), text: loc?.planner ?? 'Tasks & Projects'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.icon(
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Plan'),
                  onPressed: () => _runPlanner(context),
                ),
              ),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                HabitsView(),
                TasksView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _runPlanner(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.loggedInUser;
    if (user == null) return;

    final planner = PlannerAlgorithmService();
    final today = DateTime.now();

    // Plan for the next 7 days
    final List<Appointment> allGenerated = [];
    final List<PlanWarning> allWarnings = [];

    // Remove old calculated appointments first
    user.calendar.appointments.removeWhere((a) => a.calculated);

    for (int i = 0; i < 7; i++) {
      final day = DateTime(today.year, today.month, today.day + i);
      final result = planner.planDay(
        day: day,
        existingAppointments: user.calendar.appointments,
        tasks: user.tasks,
        habits: user.habits,
      );
      allGenerated.addAll(result.generatedAppointments);
      allWarnings.addAll(result.warnings);
    }

    // Add generated appointments
    user.calendar.appointments.addAll(allGenerated);
    appState.notifyListeners();

    // Show result
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_fix_high, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text('Plan Result (${allGenerated.length} appointments)'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (allGenerated.isNotEmpty) ...[
                  const Text('Generated:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...allGenerated.map((a) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.event, size: 20),
                    title: Text(a.title),
                    subtitle: Text(
                      '${a.start.day}.${a.start.month}. ${a.start.hour.toString().padLeft(2, '0')}:${a.start.minute.toString().padLeft(2, '0')} – ${a.end.hour.toString().padLeft(2, '0')}:${a.end.minute.toString().padLeft(2, '0')}',
                    ),
                  )),
                ],
                if (allWarnings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Warnings:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ...allWarnings.map((w) => ListTile(
                    dense: true,
                    leading: Icon(
                      w.severity == WarningSeverity.critical ? Icons.error : Icons.warning,
                      color: w.severity == WarningSeverity.critical ? Colors.red : Colors.orange,
                      size: 20,
                    ),
                    title: Text(w.message, style: TextStyle(
                      color: w.severity == WarningSeverity.critical ? Colors.red : null,
                    )),
                  )),
                ],
                if (allGenerated.isEmpty && allWarnings.isEmpty)
                  const Text('Nothing to plan. Add tasks or habits with deadlines first.'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}
