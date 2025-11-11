import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';

enum PlayBarViewType { full, compact }

class PlayBar extends StatefulWidget {
  final PlayBarViewType viewType;
  const PlayBar({super.key, this.viewType = PlayBarViewType.full});

  @override
  State<PlayBar> createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppState>(context);
    if (appState.currentlyTracking != null &&
        (_timer == null || !_timer!.isActive)) {
      _startTimer(appState.trackingStartTime);
    } else if (appState.currentlyTracking == null) {
      _timer?.cancel();
      _timer = null;
      if (mounted) {
        setState(() {
          _duration = Duration.zero;
        });
      }
    }
  }

  void _startTimer(DateTime? startTime) {
    if (startTime == null) return;
    _timer?.cancel(); // Ensure no multiple timers are running
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration = DateTime.now().difference(startTime);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showActivitySelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const _ActivitySelectionDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isPlaying = appState.currentlyTracking != null;
        final activityName =
            appState.currentlyTracking?.name ??
            appState.selectedActivity?.name ??
            'No activity selected';

        if (widget.viewType == PlayBarViewType.compact) {
          return FloatingActionButton(
            onPressed: () {
              if (isPlaying) {
                appState.stopTracking();
              } else if (appState.selectedActivity != null) {
                appState.startTracking();
              } else {
                _showActivitySelection(context);
              }
            },
            child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
          );
        }
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  color: isPlaying ? Colors.redAccent : Colors.greenAccent,
                ),
                iconSize: 24,
                onPressed: () {
                  if (isPlaying) {
                    appState.stopTracking();
                  } else if (appState.selectedActivity != null) {
                    appState.startTracking();
                  } else {
                    _showActivitySelection(context);
                  }
                },
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      activityName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isPlaying)
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.list_alt_rounded),
                iconSize: 24,
                onPressed: () => _showActivitySelection(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivitySelectionDialog extends StatefulWidget {
  const _ActivitySelectionDialog();

  @override
  State<_ActivitySelectionDialog> createState() =>
      _ActivitySelectionDialogState();
}

class _ActivitySelectionDialogState extends State<_ActivitySelectionDialog> {
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final activities = appState.getSelectableActivities();
    final categories = appState.loggedInUser?.customCategories ?? [];

    // Find suggested activity
    final now = DateTime.now();
    Appointment? currentAppointment;
    try {
      currentAppointment = appState.loggedInUser?.calendar.appointments
          .firstWhere((app) => now.isAfter(app.start) && now.isBefore(app.end));
    } catch (e) {
      currentAppointment = null;
    }
    final suggestedActivity = currentAppointment != null
        ? SelectableActivity(
            name: currentAppointment.title,
            category: currentAppointment.category,
            original: currentAppointment,
          )
        : null;

    final filteredActivities = _selectedCategory == null
        ? activities
        : activities
              .where((a) => a.category.name == _selectedCategory!.name)
              .toList();

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<Category>(
            hint: const Text("Category"),
            value: _selectedCategory,
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (cat) {
              setState(() {
                _selectedCategory = cat;
              });
            },
          ),
          const Text('Select Activity'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (suggestedActivity != null)
              ListTile(
                title: Text(suggestedActivity.name),
                subtitle: const Text("Suggested from calendar"),
                leading: const Icon(Icons.star, color: Colors.amber),
                onTap: () {
                  appState.setSelectedActivity(suggestedActivity);
                  Navigator.of(context).pop();
                },
              ),
            if (suggestedActivity != null) const Divider(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredActivities.length,
                itemBuilder: (context, index) {
                  final activity = filteredActivities[index];
                  return ListTile(
                    title: Text(activity.name),
                    leading: Icon(Icons.circle, color: activity.category.color),
                    onTap: () {
                      appState.setSelectedActivity(activity);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
