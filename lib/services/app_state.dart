import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/appointment.dart';

class AppState extends ChangeNotifier {
  User? _loggedInUser;
  final List<User> _users = [];

  User? get loggedInUser => _loggedInUser;

  AppState() {
    // Create dummy users for the app
    _initializeUsers();
  }

  void _initializeUsers() {
    // The debug user from the login screen
    final user1 = User(
      person: Person(fullName: 'Test User', dateOfBirth: DateTime(1995, 5, 23), email: 'test@debug.com'),
      contacts: [
        Person(fullName: 'Jane Smith', dateOfBirth: DateTime(1992, 5, 10)),
        Person(fullName: 'Peter Jones', dateOfBirth: DateTime(1988, 11, 22)),
      ],
      calendar: Calendar(appointments: [
        Appointment(
          title: 'Morning Standup',
          start: DateTime.now().copyWith(hour: 9, minute: 0, second: 0),
          end: DateTime.now().copyWith(hour: 9, minute: 30, second: 0),
        ),
        Appointment(
          title: 'Lunch with Jane',
          start: DateTime.now().copyWith(hour: 12, minute: 30, second: 0),
          end: DateTime.now().copyWith(hour: 13, minute: 30, second: 0),
        ),
         Appointment(
          title: 'Dentist Appointment',
          start: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 14, minute: 0, second: 0),
          end: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 15, minute: 0, second: 0),
        ),
      ]),
    );

    _users.add(user1);
    // Add more dummy users if needed
  }

  Future<bool> login(String email, String password) async {
    // In a real app, you'd verify the password hash. Here, we just check the debug password.
    if (password == 'debug123') {
      try {
        _loggedInUser = _users.firstWhere((user) => user.person.email == email);
        notifyListeners();
        return true;
      } catch (e) {
        _loggedInUser = null;
        return false;
      }
    } else {
      return false;
    }
  }

  void logout() {
    _loggedInUser = null;
    notifyListeners();
  }

  void updateUserName(String newName) {
    if (_loggedInUser != null) {
      _loggedInUser!.person = Person(
        fullName: newName,
        dateOfBirth: _loggedInUser!.person.dateOfBirth,
        email: _loggedInUser!.person.email,
        nickname: _loggedInUser!.person.nickname,
        address: _loggedInUser!.person.address,
        profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
      );
      notifyListeners();
    }
  }

  void updateUserEmail(String newEmail) {
    if (_loggedInUser != null) {
      _loggedInUser!.person = Person(
        fullName: _loggedInUser!.person.fullName,
        dateOfBirth: _loggedInUser!.person.dateOfBirth,
        email: newEmail,
        nickname: _loggedInUser!.person.nickname,
        address: _loggedInUser!.person.address,
        profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
      );
      notifyListeners();
    }
  }

  void updateUserNickname(String newNickname) {
    if (_loggedInUser != null) {
      _loggedInUser!.person = Person(
        fullName: _loggedInUser!.person.fullName,
        dateOfBirth: _loggedInUser!.person.dateOfBirth,
        email: _loggedInUser!.person.email,
        nickname: newNickname,
        address: _loggedInUser!.person.address,
        profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
      );
      notifyListeners();
    }
  }

  void updateUserAddress(String newAddress) {
    if (_loggedInUser != null) {
      _loggedInUser!.person = Person(
        fullName: _loggedInUser!.person.fullName,
        dateOfBirth: _loggedInUser!.person.dateOfBirth,
        email: _loggedInUser!.person.email,
        nickname: _loggedInUser!.person.nickname,
        address: newAddress,
        profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
      );
      notifyListeners();
    }
  }

  void updateUserDateOfBirth(DateTime newDateOfBirth) {
    if (_loggedInUser != null) {
      _loggedInUser!.person = Person(
        fullName: _loggedInUser!.person.fullName,
        dateOfBirth: newDateOfBirth,
        email: _loggedInUser!.person.email,
        nickname: _loggedInUser!.person.nickname,
        address: _loggedInUser!.person.address,
        profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
      );
      notifyListeners();
    }
  }
}