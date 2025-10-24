import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/person.dart';

class User {
  final Person person;
  final List<Person> contacts;
  final Calendar calendar;

  User({
    required this.person,
    required this.contacts,
    required this.calendar,
  });
}
