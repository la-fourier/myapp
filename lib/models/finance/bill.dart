import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/finance/attachment.dart';

class LineItem {
  final String description;
  final double amount;

  LineItem({required this.description, required this.amount});

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      description: json['description'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
    };
  }
}

class Bill implements Attachment {
  final String vendor;
  final List<LineItem> items;
  final DateTime date;
  final Category category;

  Bill({
    required this.vendor,
    required this.items,
    required this.date,
    required this.category,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.amount);

  @override
  String get name => 'Bill from $vendor';

  @override
  String get type => 'Bill';

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      vendor: json['vendor'],
      items: (json['items'] as List).map((item) => LineItem.fromJson(item)).toList(),
      date: DateTime.parse(json['date']),
      category: Category.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor': vendor,
      'items': items.map((item) => item.toJson()).toList(),
      'date': date.toIso8601String(),
      'category': category.toJson(),
      'attachmentType': type, // To help with deserialization
    };
  }
}

