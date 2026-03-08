import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/finance/bill.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/task_item.dart';

class User {
  Person person;
  List<Person> contacts;
  final Calendar calendar;
  List<Category> customCategories;
  List<Bill> bills;
  List<Habit> habits;
  List<TaskItem> tasks;
  double accountBalance;
  String password;
  String? linkedAccountId;

  User({
    required this.person,
    required this.contacts,
    required this.calendar,
    List<Category>? customCategories,
    List<Bill>? bills,
    List<Habit>? habits,
    List<TaskItem>? tasks,
    this.accountBalance = 0.0,
    required this.password,
    this.linkedAccountId,
  })  : customCategories = customCategories ?? [],
        bills = bills ?? [],
        habits = habits ?? [],
        tasks = tasks ?? [];

  void updatePerson(Person newPerson) {
    person = newPerson;
  }

  void deleteContact(Person contact) {
    contacts.removeWhere((c) => c == contact);
  }

  void updateUserDateOfBirth(DateTime newDate) {
    person = Person(
      uid: person.uid,
      fullName: person.fullName,
      dateOfBirth: newDate,
      nickname: person.nickname,
      profilePictureUrl: person.profilePictureUrl,
      address: person.address,
      email: person.email,
      phoneNumber: person.phoneNumber,
    );
  }

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
          ? (json['bills'] as List).map((e) => Bill.fromJson(e)).toList()
          : [],
      habits: json['habits'] != null
          ? (json['habits'] as List).map((e) => Habit.fromJson(e)).toList()
          : [],
      tasks: json['tasks'] != null
          ? (json['tasks'] as List).map((e) => TaskItem.fromJson(e)).toList()
          : [],
      accountBalance: json['accountBalance'] ?? 0.0,
      password: json['password'],
      linkedAccountId: json['linkedAccountId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person.toJson(),
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'calendar': calendar.toJson(),
      'customCategories': customCategories.map((e) => e.toJson()).toList(),
      'bills': bills.map((e) => e.toJson()).toList(),
      'habits': habits.map((e) => e.toJson()).toList(),
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'accountBalance': accountBalance,
      'password': password,
      'linkedAccountId': linkedAccountId,
    };
  }
}
