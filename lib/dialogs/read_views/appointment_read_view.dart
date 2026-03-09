import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final dateFormat = DateFormat.yMMMEd();
    final timeFormat = DateFormat.Hm();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
       child: Container(
         constraints: const BoxConstraints(maxWidth: 450),
         decoration: BoxDecoration(
           color: theme.colorScheme.surface.withOpacity(0.95),
           borderRadius: BorderRadius.circular(28),
           border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.1),
               blurRadius: 20,
               offset: const Offset(0, 10),
             ),
           ],
         ),
         child: ClipRRect(
           borderRadius: BorderRadius.circular(28),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               // Header with category color
               Container(
                 width: double.infinity,
                 height: 120,
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                     colors: [
                       appointment.category.color,
                       appointment.category.color.withOpacity(0.7),
                     ],
                   ),
                 ),
                 child: Stack(
                   children: [
                     Positioned(
                       bottom: 16,
                       left: 20,
                       right: 60,
                       child: Text(
                         appointment.title,
                         style: theme.textTheme.headlineSmall?.copyWith(
                           color: Colors.white,
                           fontWeight: FontWeight.bold,
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     Positioned(
                       top: 8,
                       right: 8,
                       child: IconButton(
                         icon: const Icon(Icons.close, color: Colors.white),
                         onPressed: onClose ?? () => Navigator.pop(context),
                       ),
                     ),
                   ],
                 ),
               ),
               
               Padding(
                 padding: const EdgeInsets.all(24),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildInfoItem(
                       context,
                       Icons.event_outlined,
                       dateFormat.format(appointment.start),
                       '${timeFormat.format(appointment.start)} - ${timeFormat.format(appointment.end)}',
                     ),
                     const SizedBox(height: 20),
                     _buildInfoItem(
                       context,
                       Icons.category_outlined,
                       'Category',
                       appointment.category.name,
                     ),
                     if (appointment.address != null && appointment.address!.isNotEmpty) ...[
                       const SizedBox(height: 20),
                       _buildInfoItem(
                         context,
                         Icons.location_on_outlined,
                         'Address',
                         appointment.address!,
                       ),
                     ],
                     if (appointment.calculated) ...[
                       const SizedBox(height: 12),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: theme.colorScheme.secondaryContainer,
                           borderRadius: BorderRadius.circular(16),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(Icons.auto_fix_high, size: 16, color: colorScheme.onSecondaryContainer),
                             const SizedBox(width: 6),
                             Text('Calculated',
                               style: theme.textTheme.labelSmall?.copyWith(
                                 color: colorScheme.onSecondaryContainer,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                     if (appointment.description != null && appointment.description!.isNotEmpty) ...[
                       const SizedBox(height: 20),
                       _buildInfoItem(
                         context,
                         Icons.description_outlined,
                         'Description',
                         appointment.description!,
                       ),
                     ],
                     const SizedBox(height: 32),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         if (onEdit != null)
                           FilledButton.icon(
                             onPressed: onEdit,
                             icon: const Icon(Icons.edit_outlined, size: 20),
                             label: Text(loc?.edit ?? 'Edit'),
                           ),
                         const SizedBox(width: 12),
                         TextButton(
                           onPressed: onClose ?? () => Navigator.pop(context),
                           child: Text(loc?.close ?? 'Close'),
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),
       ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
