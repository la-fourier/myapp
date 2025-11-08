import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  void _scanBill(BuildContext context) {
    // Placeholder for camera functionality
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scan Bill'),
          content: const Text('Camera functionality is not implemented. Please enter bill details manually.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Open a manual bill entry dialog
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
                      const Text('Account Balance', style: TextStyle(fontSize: 20)),
                      Text(
                        currencyFormat.format(user.accountBalance),
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
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
              },
              childCount: user.bills.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scanBill(context),
        label: const Text('Scan Bill'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
