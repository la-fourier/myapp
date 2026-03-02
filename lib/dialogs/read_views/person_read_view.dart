import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/person.dart';

class PersonReadView extends StatelessWidget {
  final Person person;
  final VoidCallback? onEdit;
  final VoidCallback? onClose;

  const PersonReadView({
    super.key,
    required this.person,
    this.onEdit,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
         width: double.infinity,
         maxWidth: 450,
         padding: const EdgeInsets.all(24),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             // Header Row
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 CircleAvatar(
                   radius: 32,
                   backgroundColor: colorScheme.primaryContainer,
                   backgroundImage: person.profilePictureUrl != null
                       ? NetworkImage(person.profilePictureUrl!)
                       : null,
                   child: person.profilePictureUrl == null
                       ? Icon(Icons.person, size: 32, color: colorScheme.onPrimaryContainer)
                       : null,
                 ),
                 Row(
                   children: [
                     if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit Contact',
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
             const SizedBox(height: 24),
             
             // Content List
             Flexible(
               child: SingleChildScrollView(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildDataRow(context, Icons.badge_outlined, 'Full Name', person.fullName),
                     if (person.nickname != null && person.nickname!.isNotEmpty)
                       _buildDataRow(context, Icons.tag_faces_outlined, 'Nickname', person.nickname!),
                     _buildDataRow(context, Icons.cake_outlined, 'Date of Birth', DateFormat.yMMMMd().format(person.dateOfBirth)),
                     if (person.email != null && person.email!.isNotEmpty)
                       _buildDataRow(context, Icons.email_outlined, 'Email', person.email!),
                     if (person.address != null && person.address!.isNotEmpty)
                       _buildDataRow(context, Icons.home_outlined, 'Address', person.address!),
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
