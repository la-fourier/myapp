import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/calendar/appointment.dart';

class AppointmentReadView extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onEdit;
  final VoidCallback? onClose;

  const AppointmentReadView({
    super.key,
    required this.appointment,
    this.onEdit,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final dateFormat = DateFormat.yMMMEd();
    final timeFormat = DateFormat.Hm();

    return Dialog(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       elevation: 4,
       child: Container(
         width: double.infinity,
         maxWidth: 500,
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
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Container(
                         width: 16,
                         height: 48,
                         decoration: BoxDecoration(
                           color: appointment.category.color,
                           borderRadius: BorderRadius.circular(4),
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               appointment.title,
                               style: theme.textTheme.headlineSmall?.copyWith(
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             const SizedBox(height: 4),
                             Text(
                               appointment.category.name,
                               style: theme.textTheme.bodyMedium?.copyWith(
                                 color: colorScheme.onSurfaceVariant,
                                 fontWeight: FontWeight.w500,
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
                        tooltip: 'Edit Appointment',
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
                       Icons.schedule,
                       'Time',
                       '${dateFormat.format(appointment.start)}  ${timeFormat.format(appointment.start)} - ${timeFormat.format(appointment.end)}',
                     ),
                     
                     if (appointment.description != null && appointment.description!.isNotEmpty)
                       _buildDataRow(
                         context,
                         Icons.notes,
                         'Description',
                         appointment.description!,
                       ),
                       
                     _buildDataRow(
                       context,
                       Icons.priority_high,
                       'Priority',
                       appointment.priority.toString(),
                     ),
                     
                     if (appointment.attachments.isNotEmpty) ...[
                       const SizedBox(height: 16),
                       Text(
                         'Attachments (${appointment.attachments.length})',
                         style: theme.textTheme.titleSmall?.copyWith(
                           color: colorScheme.onSurfaceVariant,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       const SizedBox(height: 8),
                       ...appointment.attachments.map((file) => ListTile(
                         contentPadding: EdgeInsets.zero,
                         leading: const Icon(Icons.attach_file),
                         title: Text(file.name),
                         subtitle: Text(file.type),
                       )),
                     ]
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
