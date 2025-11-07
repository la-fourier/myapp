import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/calendar/tracked_activity.dart';
import 'package:myapp/services/storage_service.dart';

import 'package:fluttertoast/fluttertoast.dart';

// Helper class for the activity selection UI
class SelectableActivity {
  final String name;
  final Category category;
  final dynamic original;

  SelectableActivity({
    required this.name,
    required this.category,
    this.original,
  });
}

class AppState extends ChangeNotifier {
  User? _loggedInUser;
  List<User> _users = [];
  final StorageService _storageService = StorageService();

  // Tracking State
  SelectableActivity? _currentlyTracking;
  DateTime? _trackingStartTime;

  User? get loggedInUser => _loggedInUser;
  List<User> get users => _users;
  SelectableActivity? get currentlyTracking => _currentlyTracking;
  DateTime? get trackingStartTime => _trackingStartTime;

  AppState() {
    _loadUsers();
  }

  Future<bool> signup(String email, String password) async {
    if (_users.any((user) => user.person.email == email)) {
      return false; // User already exists
    }

    final newUser = User(
      person: Person(
        fullName: 'New User',
        dateOfBirth: DateTime(2000, 1, 1),
        email: email,
        password: password,
      ),
      contacts: [],
      calendar: Calendar(appointments: []),
      customCategories: [],
    );
    _users.add(newUser);
    _loggedInUser = newUser;
    await _saveUsers();
    notifyListeners();
    return true;
  }

  Future<void> _loadUsers() async {
    _users = await _storageService.readUsers();
    if (_users.isEmpty) {
      _initializeUsers();
    }

    final loggedInUserEmail = await _storageService.getLoggedInUser();
    if (loggedInUserEmail != null && loggedInUserEmail.isNotEmpty) {
      _loggedInUser =
          _users.firstWhereOrNull((user) => user.person.email == loggedInUserEmail);
    }

    notifyListeners();
  }

  Future<void> _saveUsers() async {
    await _storageService.saveUsers(_users);
  }

  void _initializeUsers() {
    final user1 = User(
      person: Person(
        fullName: 'Test User',
        dateOfBirth: DateTime(1995, 5, 23),
        email: 'test@debug.com',
        password: 'debug123',
      ),
      contacts: [
        Person(fullName: 'Jane Smith', dateOfBirth: DateTime(1992, 5, 10)),
        Person(fullName: 'Peter Jones', dateOfBirth: DateTime(1988, 11, 22)),
      ],
      calendar: Calendar(
        appointments: [
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
            start: DateTime.now()
                .add(const Duration(days: 1))
                .copyWith(hour: 14, minute: 0, second: 0),
            end: DateTime.now()
                .add(const Duration(days: 1))
                .copyWith(hour: 15, minute: 0, second: 0),
          ),
        ],
      ),
      customCategories: [
        Category(name: 'Work', color: Colors.blue),
        Category(name: 'Personal', color: Colors.green),
        Category(name: 'Fitness', color: Colors.orange),
      ],
    );

    _users.add(user1);
    _saveUsers();
  }

  // AUTHENTICATION
  Future<bool> login(String email, String password) async {
    final user = _users.firstWhereOrNull((user) => user.person.email == email);

    if (user != null && user.person.password == password) {
      _loggedInUser = user;
      await _storageService.saveLoggedInUser(email);
      notifyListeners();
      return true;
    } else {
      _loggedInUser = null;
      return false;
    }
  }

  void logout() {
    _loggedInUser = null;
    _storageService.saveLoggedInUser('');
    notifyListeners();
  }

  // ACTIVITY TRACKING
  List<SelectableActivity> getSelectableActivities() {
    if (_loggedInUser == null) return [];

    final fromAppointments = _loggedInUser!.calendar.appointments.map(
      (e) =>
          SelectableActivity(name: e.title, category: e.category, original: e),
    );

    final fromCategories = _loggedInUser!.customCategories.map(
      (e) => SelectableActivity(name: e.name, category: e, original: e),
    );

    return [...fromAppointments, ...fromCategories];
  }

  void startTracking(SelectableActivity activity) {
    if (_currentlyTracking != null) {
      stopTracking(); // Stop previous activity before starting a new one
    }
    _currentlyTracking = activity;
    _trackingStartTime = DateTime.now();
    notifyListeners();
  }

  void stopTracking() {
    if (_currentlyTracking != null &&
        _trackingStartTime != null &&
        _loggedInUser != null) {
      final trackedActivity = TrackedActivity(
        name: _currentlyTracking!.name,
        category: _currentlyTracking!.category,
        startTime: _trackingStartTime!,
        endTime: DateTime.now(),
      );
      _loggedInUser!.calendar.trackedActivities.add(trackedActivity);
      _currentlyTracking = null;
      _trackingStartTime = null;
      _saveUsers();
      notifyListeners();
    }
  }

  // DATA MANAGEMENT
  void addItem<T>(T item) {
    if (_loggedInUser != null) {
      if (T == Category) {
        _loggedInUser!.customCategories.add(item as Category);
      } else if (T == Appointment) {
        _loggedInUser!.calendar.appointments.add(item as Appointment);
      } else if (T == Person) {
        _loggedInUser!.contacts.add(item as Person);
      }
      _saveUsers();
      notifyListeners();
    }
  }

  void updateItem<T>(T oldItem, T newItem) {
    if (_loggedInUser != null) {
      if (T == Category) {
        final index = _loggedInUser!.customCategories.indexOf(oldItem as Category);
        if (index != -1) {
          _loggedInUser!.customCategories[index] = newItem as Category;
        }
      } else if (T == Appointment) {
        final index = _loggedInUser!.calendar.appointments.indexOf(oldItem as Appointment);
        if (index != -1) {
          _loggedInUser!.calendar.appointments[index] = newItem as Appointment;
        }
      } else if (T == Person) {
        final index = _loggedInUser!.contacts.indexOf(oldItem as Person);
        if (index != -1) {
          _loggedInUser!.contacts[index] = newItem as Person;
        }
      }
      _saveUsers();
      notifyListeners();
    }
  }

  void deleteItem<T>(T item) {
    if (_loggedInUser != null) {
      if (T == Category) {
        _loggedInUser!.customCategories.remove(item as Category);
      } else if (T == Appointment) {
        _loggedInUser!.calendar.appointments.remove(item as Appointment);
      } else if (T == Person) {
        _loggedInUser!.contacts.remove(item as Person);
      }
      _saveUsers();
      notifyListeners();
    }
  }

  // USER PROFILE MANAGEMENT
  void updateUser(User user) {
    if (_loggedInUser != null) {
      _loggedInUser = user;
      _saveUsers();
      notifyListeners();
    }
  }
}
