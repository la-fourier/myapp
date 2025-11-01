import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/person.dart';

class User {
  Person person;
  final List<Person> contacts;
  final Calendar calendar;
  final List<Category> customCategories;

  User({
    required this.person,
    required this.contacts,
    required this.calendar,
    this.customCategories = const [],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person.toJson(),
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'calendar': calendar.toJson(),
      'customCategories': customCategories.map((e) => e.toJson()).toList(),
    };
  }
}