import 'package:flutter/material.dart';
import 'package:myapp/models/calendar/appointment.dart';

class PlayBar extends StatefulWidget {
  final Appointment currentAppointment;
  bool isPlaying;
  PlayBar({super.key, required this.currentAppointment, required this.isPlaying});

  @override
  State<PlayBar> createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  Appointment get currentAppointment => widget.currentAppointment;
  bool get isPlaying => widget.isPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.blueGrey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: isPlaying ? const Icon(Icons.pause, color: Colors.redAccent) : const Icon(Icons.play_arrow_rounded, color: Colors.redAccent),
            onPressed: () {
              if (isPlaying) {
                // Pause logic
              } else {
                // Play logic
              }
              setState(() {
                this.widget.isPlaying = !isPlaying;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
            onPressed: () {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: const Text('Choose Next'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Option 1'),
                        onTap: () {
                          // Handle option 1
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  elevation: 24.0,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Confirm'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle skip action
                        Navigator.of(context).pop();
                      },
                      child: const Text('Skip'),
                    ),
                  ],
                );
              });
            },
          ),
          Card(
            color: const Color.fromARGB(255, 239, 227, 203),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.currentAppointment.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}