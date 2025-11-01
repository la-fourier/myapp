import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/calendar/tracked_activity.dart';
import 'package:myapp/services/storage_service.dart';

// Helper class for the activity selection UI
class SelectableActivity {
  final String name;
  final Category category;
  final dynamic original;

  SelectableActivity({required this.name, required this.category, this.original});
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

  Future<void> _loadUsers() async {
    _users = await _storageService.readUsers();
    if (_users.isEmpty) {
      _initializeUsers();
    } else {
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
      customCategories: [
        Category(name: 'Work', color: Colors.blue),
        Category(name: 'Personal', color: Colors.green),
        Category(name: 'Fitness', color: Colors.orange),
      ]
    );

    _users.add(user1);
    _saveUsers();
  }

  // AUTHENTICATION
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

  // ACTIVITY TRACKING
  List<SelectableActivity> getSelectableActivities() {
    if (_loggedInUser == null) return [];

    final fromAppointments = _loggedInUser!.calendar.appointments.map((e) => 
      SelectableActivity(name: e.title, category: e.category, original: e)
    );

    final fromCategories = _loggedInUser!.customCategories.map((e) => 
      SelectableActivity(name: e.name, category: e, original: e)
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
    if (_currentlyTracking != null && _trackingStartTime != null && _loggedInUser != null) {
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

  // CATEGORY MANAGEMENT
  void addCustomCategory(Category category) {
    if (_loggedInUser != null) {
      _loggedInUser!.customCategories.add(category);
      _saveUsers();
      notifyListeners();
    }
  }

  void updateCustomCategory(Category oldCategory, Category newCategory) {
    if (_loggedInUser != null) {
      final index = _loggedInUser!.customCategories.indexOf(oldCategory);
      if (index != -1) {
        _loggedInUser!.customCategories[index] = newCategory;
        _saveUsers();
        notifyListeners();
      }
    }
  }

  void deleteCustomCategory(Category category) {
    if (_loggedInUser != null) {
      _loggedInUser!.customCategories.remove(category);
      _saveUsers();
      notifyListeners();
    }
  }

  // APPOINTMENT MANAGEMENT
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

  // USER PROFILE MANAGEMENT
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