import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/finance/bill.dart';
import 'package:myapp/models/person.dart';

class User {
  Person person;
  final List<Person> contacts;
  final Calendar calendar;
  final List<Category> customCategories;
  final List<Bill> bills;
  final double accountBalance;

  User({
    required this.person,
    required this.contacts,
    required this.calendar,
    this.customCategories = const [],
    this.bills = const [],
    this.accountBalance = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      person: Person.fromJson(json['person']),
      contacts: (json['contacts'] as List)
          .map((e) => Person.fromJson(e))
          .toList(),
      calendar: Calendar.fromJson(json['calendar']),
      customCategories: json['customCategories'] != null
          ? (json['customCategories'] as List)
              .map((e) => Category.fromJson(e))
              .toList()
          : [],
      bills: json['bills'] != null
          ? (json['bills'] as List)
              .map((e) => Bill.fromJson(e))
              .toList()
          : [],
      accountBalance: json['accountBalance'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person.toJson(),
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'calendar': calendar.toJson(),
      'customCategories': customCategories.map((e) => e.toJson()).toList(),
      'bills': bills.map((e) => e.toJson()).toList(),
      'accountBalance': accountBalance,
    };
  }
}