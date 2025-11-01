import 'dart:async';
import 'package:flutter/material.dart';
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
    if (appState.currentlyTracking != null && (_timer == null || !_timer!.isActive)) {
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
    final appState = Provider.of<AppState>(context, listen: false);
    final activities = appState.getSelectableActivities();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Activity'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  title: Text(activity.name),
                  leading: Icon(Icons.circle, color: activity.category.color),
                  onTap: () {
                    appState.startTracking(activity);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isPlaying = appState.currentlyTracking != null;

        if (widget.viewType == PlayBarViewType.compact) {
          return FloatingActionButton(
            onPressed: () {
              if (isPlaying) {
                appState.stopTracking();
              } else {
                _showActivitySelection(context);
              }
            },
            child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
          );
        }

        final activityName = appState.currentlyTracking?.name ?? 'No activity selected';

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
                icon: Icon(isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline, color: isPlaying ? Colors.redAccent : Colors.greenAccent),
                iconSize: 24,
                onPressed: () {
                  if (isPlaying) {
                    appState.stopTracking();
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isPlaying)
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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