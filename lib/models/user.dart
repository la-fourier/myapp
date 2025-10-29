import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/person.dart';

class User {
  Person person;
  final List<Person> contacts;
  final Calendar calendar;

  User({
    required this.person,
    required this.contacts,
    required this.calendar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      person: Person.fromJson(json['person']),
      contacts: (json['contacts'] as List)
          .map((e) => Person.fromJson(e))
          .toList(),
      calendar: Calendar.fromJson(json['calendar']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person.toJson(),
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'calendar': calendar.toJson(),
    };
  }
}