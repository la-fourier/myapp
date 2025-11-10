import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/dialogs/bill_editor_dialog.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  void _showBillEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BillEditorDialog(
        onSave: (bill) {
          Provider.of<AppState>(
            context,
            listen: false,
          ).loggedInUser?.bills.add(bill);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _scanBillWithCamera(BuildContext context) async {
    final picker = ImagePicker();
    // We don't do anything with the image for now, as OCR is not implemented.
    // But this simulates the scanning process.
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null && context.mounted) {
      // After "scanning", open the manual entry dialog.
      // In a real app, you might pre-fill some fields from OCR here.
      _showBillEntryDialog(context);
    }
  }

  void _scanBill(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Bill'),
          content: const Text('How would you like to add a bill?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _scanBillWithCamera(context);
              },
              child: const Text('Scan with Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showBillEntryDialog(context);
              },
              child: const Text('Enter Manually'),
            ),
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
    final appState = Provider.of<AppState>(context);
    final user = appState.loggedInUser;

    if (user == null) {
      return const Center(child: Text('No user logged in.'));
    }

    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Finances'),
            pinned: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Account Balance',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        currencyFormat.format(user.accountBalance),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final bill = user.bills[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: bill.category.color,
                  child: const Icon(Icons.receipt, color: Colors.white),
                ),
                title: Text(bill.vendor),
                subtitle: Text(DateFormat.yMd().format(bill.date)),
                trailing: Text(currencyFormat.format(bill.totalAmount)),
                onTap: () {
                  // TODO: Show bill details
                },
              );
            }, childCount: user.bills.length),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scanBill(context),
        label: const Text('Add Bill'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
