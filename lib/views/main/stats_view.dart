import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/models/task_item.dart';
import 'package:myapp/models/calendar/tracked_activity.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.loggedInUser;
    if (user == null) {
      return const Center(child: Text('Not logged in.'));
    }

    final tasks = user.tasks;
    final habits = user.habits;
    final activities = user.calendar.trackedActivities;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Project & Task Progress ---
          Text('Tasks & Projects', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No tasks yet.')))
          else
            ...tasks.map((item) => _buildTaskProgressCard(context, item, activities)),

          const SizedBox(height: 24),

          // --- Habit Streaks ---
          Text('Habits', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (habits.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No habits yet.')))
          else
            ...habits.map((habit) {
              // Count activities matching this habit's name in the last 7 days
              final now = DateTime.now();
              final weekAgo = now.subtract(const Duration(days: 7));
              final thisWeek = activities.where((a) =>
                a.name == habit.name &&
                a.startTime.isAfter(weekAgo)).toList();
              final totalMinutes = thisWeek.fold<int>(0, (sum, a) => sum + a.duration.inMinutes);
              final targetPerWeek = habit.frequencyPerWeek;
              final completionRate = targetPerWeek > 0
                  ? (thisWeek.length / targetPerWeek).clamp(0.0, 1.0)
                  : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.repeat, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          Text('${thisWeek.length} / $targetPerWeek this week'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: completionRate,
                          minHeight: 10,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          color: completionRate >= 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${totalMinutes}min tracked this week', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),

          // --- Activity Summary ---
          Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildWeeklyActivityChart(context, activities),
        ],
      ),
    );
  }

  Widget _buildTaskProgressCard(BuildContext context, TaskItem item, List<TrackedActivity> activities) {
    if (item is Task) {
      // Calculate worked duration from sessions
      final sessions = activities.where((a) => item.sessionIds.contains(a.id)).toList();
      final workedDuration = sessions.fold<Duration>(Duration.zero, (sum, a) => sum + a.duration);
      final progress = item.computeProgress(workedDuration);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: _progressColor(progress)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  Text('${(progress * 100).toInt()}%'),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: _progressColor(progress),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${workedDuration.inMinutes}min / ${item.duration.inMinutes}min',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    } else if (item is Project) {
      // Aggregate children
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          leading: const Icon(Icons.folder),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.children.length} items'),
          children: item.children.map((child) => Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildTaskProgressCard(context, child, activities),
          )).toList(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _progressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.6) return Colors.blue;
    if (progress >= 0.3) return Colors.orange;
    return Colors.red.shade300;
  }

  Widget _buildWeeklyActivityChart(BuildContext context, List<TrackedActivity> activities) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final dayData = days.map((day) {
      final dayActivities = activities.where((a) =>
        a.startTime.year == day.year &&
        a.startTime.month == day.month &&
        a.startTime.day == day.day).toList();
      final totalMinutes = dayActivities.fold<int>(0, (sum, a) => sum + a.duration.inMinutes);
      return totalMinutes;
    }).toList();

    final maxMinutes = dayData.reduce((a, b) => a > b ? a : b).clamp(1, 999999);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final fraction = dayData[i] / maxMinutes;
              final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][days[i].weekday - 1];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${dayData[i]}m', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Container(
                        height: (fraction * 100).clamp(4.0, 100.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7 + fraction * 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(dayName, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
