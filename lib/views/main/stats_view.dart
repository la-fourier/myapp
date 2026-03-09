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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            isScrollable: true,
            tabs: const [
              Tab(text: 'Tasks & Habits'),
              Tab(text: 'Weekly Review'),
              Tab(text: 'Timeline'),
              Tab(text: 'Plan Archive'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTasksHabitsTab(context, user),
            _buildWeeklyReviewTab(context, user),
            _buildTimelineTab(context, user),
            _buildPlanArchiveTab(context, user),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksHabitsTab(BuildContext context, user) {
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
        ],
      ),
    );
  }

  Widget _buildWeeklyReviewTab(BuildContext context, user) {
    final activities = user.calendar.trackedActivities;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildWeeklyActivityChart(context, activities),
          const SizedBox(height: 24),
          // Additional stats
          _buildStatCard(context, 'Total Time', '${activities.fold<int>(0, (sum, a) => sum + a.duration.inMinutes)} min', Icons.timer),
          const SizedBox(height: 12),
          _buildStatCard(context, 'Sessions', '${activities.length}', Icons.event_available),
          const SizedBox(height: 24),
          _buildExtraStats(Theme.of(context)),
        ],
      ),
    );
  }

  Widget _buildExtraStats(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Andere Einblicke', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatBox(theme, 'Fokus-Score', '88', Icons.psychology, Colors.purple),
            const SizedBox(width: 8),
            _buildStatBox(theme, 'Schlaf-Qualität', '7h 20m', Icons.bedtime, Colors.indigo),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withAlpha(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTab(BuildContext context, user) {
    final theme = Theme.of(context);
    final contacts = user.contacts ?? [];
    final appointments = user.calendar.appointments ?? [];
    
    final items = [
      ...contacts.map((c) => MapEntry('New Contact', c.fullName)),
      ...appointments.map((a) => MapEntry('Appointment', a.title)),
    ];

    if (items.isEmpty) {
      return const Center(child: Text('No activity history found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(item.key == 'New Contact' ? Icons.person_add : Icons.event, size: 16),
          ),
          title: Text(item.value),
          subtitle: Text(item.key),
          trailing: Text('${DateTime.now().day}.${DateTime.now().month}'),
        );
      },
    );
  }

  Widget _buildPlanArchiveTab(BuildContext context, user) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildArchiveCard(theme, 'Plan - 24.05.2024', '12 Aufgaben erledigt', '95% Erfolg'),
        _buildArchiveCard(theme, 'Plan - 23.05.2024', '8 Aufgaben erledigt', '80% Erfolg'),
        _buildArchiveCard(theme, 'Plan - 22.05.2024', '15 Aufgaben erledigt', '100% Erfolg'),
      ],
    );
  }

  Widget _buildArchiveCard(ThemeData theme, String title, String stats, String score) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(stats),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(score, style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
