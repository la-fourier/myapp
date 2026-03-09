import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/dialogs/bill_editor_dialog.dart';
import 'package:myapp/models/finance/bill.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/services/app_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

import 'package:collection/collection.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  void _showBillEntryDialog(BuildContext context, {Bill? bill}) {
    showDialog(
      context: context,
      builder: (context) => BillEditorDialog(
        bill: bill,
        onSave: (newBill) {
          Provider.of<AppState>(
            context,
            listen: false,
          ).loggedInUser?.bills.add(newBill);
          if (!context.mounted) return;
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _scanBillWithCamera(BuildContext context) async {
    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera scanning is only supported on Android/iOS. Please use the mobile emulator.')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null && context.mounted) {
      // The google_mlkit_text_recognition package uses on-device recognition,
      // so the data is processed locally and not sent to Google.
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      textRecognizer.close();

      // Heuristic parsing logic
      String? total;
      DateTime? date;
      String? vendor;
      List<LineItem> extractedItems = [];

      final priceRegex = RegExp(r'(\d+[.,]\d{2})(?!\d)');

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.toLowerCase();

          // 1. Total Extraction (look for "total" or "summe" keywords)
          if (text.contains('total') || text.contains('summe') || text.contains('betrag')) {
            final match = priceRegex.firstMatch(text);
            if (match != null) {
               total = match.group(1)?.replaceAll(',', '.');
            } else {
               // Fallback: strip everything except numbers
                total = text.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
            }
          }

          // 2. Date parsing (look for common short date formats)
          if (RegExp(r'\d{2}[./]\d{2}[./]\d{4}').hasMatch(text)) {
            try {
              // Extract just the date part if there's surrounding text
              final match = RegExp(r'(\d{2}[./]\d{2}[./]\d{4})').firstMatch(text);
              if (match != null) {
                String dateStr = match.group(1)!.replaceAll('.', '/');
                date = DateFormat('dd/MM/yyyy').parse(dateStr);
              }
            } catch (e) {
              // ignore
            }
          }

          // 3. Vendor detection (first prominent block usually)
          if (vendor == null && block == recognizedText.blocks.first) {
             // Let's assume the very first line of the first block is the store name
             if (line == block.lines.first) {
                 vendor = line.text;
             }
          }

          // 4. Line Item Extraction Heuristics
          // We look for a line that contains a price format (e.g. "1.99" or "4,50").
          // If the line has text *and* a price, we assume it's an item.
          // Ignore lines that look like totals or change given.
          if (!text.contains('total') && !text.contains('summe') && !text.contains('betrag') && !text.contains('rückgeld') && !text.contains('change')) {
              final match = priceRegex.firstMatch(line.text);
              if (match != null) {
                  // Found a price. Let's try to get the description (everything before the price)
                  String priceStr = match.group(1)!;
                  String desc = line.text.substring(0, match.start).trim();

                  // Sometimes OCR splits amount and description into different blocks/lines.
                  // For this simple heuristic, we just take lines that have both on the same line.
                  if (desc.isNotEmpty && desc.length > 2) {
                       double amount = double.tryParse(priceStr.replaceAll(',', '.')) ?? 0.0;
                       extractedItems.add(LineItem(description: desc, amount: amount));
                  }
              }
          }
        }
      }

      final totalAmount = double.tryParse(total ?? '0.0') ?? 0.0;

      // If heuristic failed to find any items, add a fallback Total item
      if (extractedItems.isEmpty) {
          extractedItems.add(LineItem(description: 'Total', amount: totalAmount));
      }

      _showBillEntryDialog(
        context,
        bill: Bill(
          vendor: vendor ?? 'Unknown',
          date: date ?? DateTime.now(),
          category: Provider.of<AppState>(context, listen: false)
                  .loggedInUser?.customCategories.first ??
              Category(name: 'Default', color: Colors.blue),
          items: extractedItems,
        ),
      );
    }
  }

  Future<void> _importFromTxt(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      if (result != null && context.mounted) {
        final file = File(result.files.single.path!);
        final lines = await file.readAsLines();
        for (var line in lines) {
          final parts = line.split(',');
          if (parts.length >= 3) {
            final totalAmount = double.tryParse(parts[2]) ?? 0.0;
            final bill = Bill(
              vendor: parts[0],
              date: DateTime.tryParse(parts[1]) ?? DateTime.now(),
              category:
                  Provider.of<AppState>(
                    context,
                    listen: false,
                  ).loggedInUser?.customCategories.first ??
                  Category(name: 'Default', color: Colors.blue),
              items: [LineItem(description: 'Total', amount: totalAmount)],
            );
            Provider.of<AppState>(
              context,
              listen: false,
            ).loggedInUser?.bills.add(bill);
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TXT file imported successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing TXT file: $e')));
    }
  }

  Future<void> _importFromCsv(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null && context.mounted) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final List<List<dynamic>> rowsAsListOfValues =
            const CsvToListConverter().convert(content);
        for (var row in rowsAsListOfValues) {
          if (row.length >= 3) {
            final totalAmount = double.tryParse(row[2].toString()) ?? 0.0;
            final bill = Bill(
              vendor: row[0].toString(),
              date: DateTime.tryParse(row[1].toString()) ?? DateTime.now(),
              category:
                  Provider.of<AppState>(
                    context,
                    listen: false,
                  ).loggedInUser?.customCategories.first ??
                  Category(name: 'Default', color: Colors.blue),
              items: [LineItem(description: 'Total', amount: totalAmount)],
            );
            Provider.of<AppState>(
              context,
              listen: false,
            ).loggedInUser?.bills.add(bill);
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV file imported successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing CSV file: $e')));
    }
  }

  Future<void> _importFromJson(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && context.mounted) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final List<dynamic> billsJson = jsonDecode(content);
        for (var billJson in billsJson) {
          final bill = Bill.fromJson(billJson);
          Provider.of<AppState>(
            context,
            listen: false,
          ).loggedInUser?.bills.add(bill);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JSON file imported successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing JSON file: $e')));
    }
  }

  void _showAddBillOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            alignment: WrapAlignment.center,
            children: [
              _buildImportOption(
                sheetContext,
                icon: Icons.camera_alt,
                label: 'Scan',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _scanBillWithCamera(context);
                },
              ),
              _buildImportOption(
                sheetContext,
                icon: Icons.text_fields,
                label: 'TXT',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _importFromTxt(context);
                },
              ),
              _buildImportOption(
                sheetContext,
                icon: Icons.grid_on,
                label: 'CSV',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _importFromCsv(context);
                },
              ),
              _buildImportOption(
                sheetContext,
                icon: Icons.data_object,
                label: 'JSON',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _importFromJson(context);
                },
              ),
              _buildImportOption(
                sheetContext,
                icon: Icons.edit,
                label: 'Manual',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showBillEntryDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImportOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return 'Today';
    } else if (dateToCompare == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.loggedInUser;

    if (user == null) {
      return const Center(child: Text('No user logged in.'));
    }

    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    // Sort bills by date descending
    final sortedBills = user.bills.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group bills by date (day)
    final groupedBills = groupBy(
      sortedBills,
      (Bill bill) => DateTime(bill.date.year, bill.date.month, bill.date.day),
    );

    final List<Widget> sliverItems = [];
    groupedBills.forEach((date, bills) {
      // Add date header
      sliverItems.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              _formatDate(context, date),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      );
      // Add bills for that date
      sliverItems.add(
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final bill = bills[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: bill.category.color,
                child: const Icon(Icons.receipt, color: Colors.white),
              ),
              title: Text(bill.vendor),
              subtitle: Text(DateFormat.yMd().format(bill.date)),
              trailing: Text(currencyFormat.format(bill.totalAmount)),
              onTap: () {
                _showBillEntryDialog(context, bill: bill);
              },
            );
          }, childCount: bills.length),
        ),
      );
    });

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
          if (user.bills.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No bills yet. Add one to get started!'),
              ),
            )
          else
            ...sliverItems,
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBillOptions(context),
        label: const Text('Add Bill'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
