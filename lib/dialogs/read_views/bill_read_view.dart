import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/finance/bill.dart';

class BillReadView extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onEdit;
  final VoidCallback? onClose;

  const BillReadView({
    super.key,
    required this.bill,
    this.onEdit,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             // Header Row
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     CircleAvatar(
                       radius: 24,
                       backgroundColor: bill.category.color.withOpacity(0.2),
                       child: Icon(Icons.receipt_long, color: bill.category.color),
                     ),
                     const SizedBox(width: 16),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           bill.vendor,
                           style: theme.textTheme.headlineSmall?.copyWith(
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         Text(
                           DateFormat.yMMMMd().format(bill.date),
                           style: theme.textTheme.bodyMedium?.copyWith(
                             color: colorScheme.onSurfaceVariant,
                           ),
                         ),
                       ],
                     ),
                   ],
                 ),
                 Row(
                   children: [
                     if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit Bill',
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
             
             // Content: Line Items
             Flexible(
               child: SingleChildScrollView(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Items',
                       style: theme.textTheme.titleMedium?.copyWith(
                         color: colorScheme.primary,
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                     const SizedBox(height: 12),
                     ...bill.items.map((item) => Padding(
                       padding: const EdgeInsets.symmetric(vertical: 6.0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Expanded(
                             child: Text(
                               item.description.isNotEmpty ? item.description : 'Item',
                               style: theme.textTheme.bodyLarge,
                             ),
                           ),
                           Text(
                             currencyFormat.format(item.amount),
                             style: theme.textTheme.bodyLarge,
                           ),
                         ],
                       ),
                     )),
                     
                     const Divider(height: 24),
                     
                     // Total
                     Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormat.format(bill.totalAmount),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
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
}
