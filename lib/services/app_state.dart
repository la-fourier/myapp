import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/services/storage_service.dart';

class AppState extends ChangeNotifier {
  User? _loggedInUser;
  List<User> _users = [];
  final StorageService _storageService = StorageService();

  User? get loggedInUser => _loggedInUser;
  List<User> get users => _users;

  AppState() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    _users = await _storageService.readUsers();
    if (_users.isEmpty) {
      _initializeUsers();
    } else {
      // If there is a logged in user, we need to find the user object from the newly loaded list
      if (_loggedInUser != null) {
        _loggedInUser = _users.firstWhere((user) => user.person.email == _loggedInUser!.person.email);
      }
    }
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    await _storageService.saveUsers(_users);
  }

  void _initializeUsers() {
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
    _saveUsers();
  }

  Future<bool> login(String email, String password) async {
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

  void addAppointment(Appointment appointment) {
    if (_loggedInUser != null) {
      _loggedInUser!.calendar.appointments.add(appointment);
      _saveUsers();
      notifyListeners();
    }
  }

  void updateAppointment(Appointment oldAppointment, Appointment newAppointment) {
    if (_loggedInUser != null) {
      final index = _loggedInUser!.calendar.appointments.indexOf(oldAppointment);
      if (index != -1) {
        _loggedInUser!.calendar.appointments[index] = newAppointment;
        _saveUsers();
        notifyListeners();
      }
    }
  }

  void deleteAppointment(Appointment appointment) {
    if (_loggedInUser != null) {
      _loggedInUser!.calendar.appointments.remove(appointment);
      _saveUsers();
      notifyListeners();
    }
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
      _saveUsers();
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
      _saveUsers();
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
      _saveUsers();
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
      _saveUsers();
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
      _saveUsers();
      notifyListeners();
    }
  }
}