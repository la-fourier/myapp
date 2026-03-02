import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/calendar/tracked_activity.dart';

class TrackedActivityReadView extends StatelessWidget {
  final TrackedActivity activity;
  final VoidCallback? onEdit;
  final VoidCallback? onClose;

  const TrackedActivityReadView({
    super.key,
    required this.activity,
    this.onEdit,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final dateFormat = DateFormat.yMMMEd();
    final timeFormat = DateFormat.Hm();
    final duration = activity.endTime.difference(activity.startTime);

    return Dialog(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       elevation: 4,
       child: Container(
         width: double.infinity,
         maxWidth: 450,
         padding: const EdgeInsets.all(24),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // Header Row
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Expanded(
                   child: Row(
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       CircleAvatar(
                         backgroundColor: activity.category.color.withOpacity(0.2),
                         child: Icon(Icons.timer, color: activity.category.color),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               activity.name,
                               style: theme.textTheme.titleLarge?.copyWith(
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             Text(
                               activity.category.name,
                               style: theme.textTheme.bodyMedium?.copyWith(
                                 color: colorScheme.onSurfaceVariant,
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
                 Row(
                   children: [
                     if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit Activity',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close),
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                      ),
                   ],
                 ),
               ],
             ),
             
             const Divider(height: 32),
             
             // Time Info
             Flexible(
               child: SingleChildScrollView(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildDataRow(
                       context,
                       Icons.calendar_today,
                       'Date',
                       dateFormat.format(activity.startTime),
                     ),
                     _buildDataRow(
                       context,
                       Icons.schedule,
                       'Time Logged',
                       '${timeFormat.format(activity.startTime)} - ${timeFormat.format(activity.endTime)}',
                     ),
                     _buildDataRow(
                       context,
                       Icons.hourglass_bottom,
                       'Total Duration',
                       '${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
                     ),
                     _buildDataRow(
                       context,
                       Icons.api,
                       'Tracking ID',
                       activity.id,
                     ),
                   ],
                 ),
               ),
             ),
           ],
         ),
       ),
    );
  }

  Widget _buildDataRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
