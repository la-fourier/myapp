import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/calendar/tracked_activity.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/task_item.dart';
import 'package:myapp/models/finance/bill.dart';
import 'package:myapp/services/storage_service.dart';

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

  // Global Settings Settings
  bool _toastNotificationsEnabled = true;
  Locale _currentLocale = const Locale('en');

  final Map<String, SingleActivator> _keybindings = {
    'new_item': const SingleActivator(LogicalKeyboardKey.keyN, alt: true),
    'search': const SingleActivator(LogicalKeyboardKey.keyF, alt: true),
  };

  User? get loggedInUser => _loggedInUser;
  List<User> get users => _users;
  SelectableActivity? get currentlyTracking => _currentlyTracking;
  DateTime? get trackingStartTime => _trackingStartTime;
  bool get toastNotificationsEnabled => _toastNotificationsEnabled;
  bool get isTracking => _currentlyTracking != null;
  Locale get currentLocale => _currentLocale;
  Map<String, SingleActivator> get keybindings => _keybindings;

  AppState() {
    _loadUsers();
  }

  void setLocale(Locale newLocale) {
    if (!['en', 'de', 'es'].contains(newLocale.languageCode)) return;
    _currentLocale = newLocale;
    notifyListeners();
  }

  void saveSettings() {
    _saveUsers(); // Settings are currently stored per user or globally in the same file for simplicity
    notifyListeners();
  }

  void setToastNotificationsEnabled(bool value) {
    _toastNotificationsEnabled = value;
    notifyListeners();
  }

  Future<bool> signup(String email, String password) async {
    final existingUser = _users.firstWhereOrNull(
      (user) => user.person.email == email,
    );

    if (existingUser != null) {
      return false; // User already exists
    }

    final newUser = User(
      person: Person(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: 'New User',
        dateOfBirth: DateTime(2000, 1, 1),
        email: email,
      ),
      contacts: [],
      calendar: Calendar(appointments: []),
      customCategories: [],
      password: password,
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
    } else {
      if (_loggedInUser != null) {
        _loggedInUser = _users.firstWhere(
          (user) => user.person.email == _loggedInUser!.person.email,
        );
      }
    }

    notifyListeners();
  }

  Future<void> _saveUsers() async {
    await _storageService.saveUsers(_users);
  }

  void _initializeUsers() {
    final user1 = User(
      person: Person(
        uid: 'user_1',
        fullName: 'Test User',
        dateOfBirth: DateTime(1995, 5, 23),
        email: 'test@debug.com',
      ),
      contacts: [
        Person(uid: 'c1', fullName: 'Jane Smith', dateOfBirth: DateTime(1992, 5, 10)),
        Person(uid: 'c2', fullName: 'Peter Jones', dateOfBirth: DateTime(1988, 11, 22)),
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
      habits: [
        Habit(
          id: 'h1',
          name: 'Drink Water',
          frequencyPerWeek: 7,
          priority: 5,
        ),
        Habit(
          id: 'h2',
          name: 'Read Book',
          frequencyPerWeek: 5,
          preferredTimeWindow: HabitTimeWindow.evening,
          priority: 3,
        ),
      ],
      tasks: [
        Task(
          id: 't1',
          name: 'Project Alpha Design',
          priority: 4,
          froggyness: 3,
          deadline: DateTime.now().add(const Duration(days: 2)),
        ),
        Project(
          id: 'p1',
          name: 'Home Renovation',
          children: [
            Task(id: 't2', name: 'Buy paint', priority: 2, froggyness: 1),
            Task(id: 't3', name: 'Paint walls', priority: 5, froggyness: 5),
          ],
        ),
      ],
      bills: [],
      accountBalance: 1500.0,
      password: 'password123',
    );

    _users.add(user1);
    _saveUsers();
  }

  // AUTHENTICATION
  Future<bool> login(String email, String password) async {
    final user = _users.where((user) => user.person.email == email).firstOrNull;

    if (user != null && user.password == password) {
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
  SelectableActivity? _selectedActivity;

  SelectableActivity? get selectedActivity => _selectedActivity;

  List<SelectableActivity> getSelectableActivities() {
    if (_loggedInUser == null) return [];

    final fromAppointments = _loggedInUser!.calendar.appointments.map(
      (e) =>
          SelectableActivity(name: e.title, category: e.category, original: e),
    );

    return fromAppointments.toList();
  }

  void setSelectedActivity(SelectableActivity activity) {
    _selectedActivity = activity;
    notifyListeners();
  }

  void startTracking() {
    if (_currentlyTracking != null) {
      stopTracking();
    }
    if (_selectedActivity != null) {
      _currentlyTracking = _selectedActivity;
      _trackingStartTime = DateTime.now();
      notifyListeners();
    }
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
      if (item is Category) {
        _loggedInUser!.customCategories.add(item);
      } else if (item is Appointment) {
        _loggedInUser!.calendar.appointments.add(item);
      } else if (item is Person) {
        _loggedInUser!.contacts.add(item);
      } else if (item is Habit) {
        _loggedInUser!.habits.add(item);
      } else if (item is TaskItem) {
        _loggedInUser!.tasks.add(item);
      } else if (item is Bill) {
        _loggedInUser!.bills.add(item);
      }
      _saveUsers();
      notifyListeners();
    }
  }

  void deleteItem<T>(T item) {
    if (_loggedInUser != null) {
      if (item is Category) {
        _loggedInUser!.customCategories.remove(item);
      } else if (item is Appointment) {
        _loggedInUser!.calendar.appointments.remove(item);
      } else if (item is Person) {
        _loggedInUser!.contacts.remove(item);
      } else if (item is Habit) {
        _loggedInUser!.habits.remove(item);
      } else if (item is TaskItem) {
        _loggedInUser!.tasks.remove(item);
      } else if (item is Bill) {
        _loggedInUser!.bills.remove(item);
      }
      _saveUsers();
      notifyListeners();
    }
  }

  void updateItem<T>(T oldItem, T newItem) {
    if (_loggedInUser != null) {
      if (oldItem is Category && newItem is Category) {
        final index = _loggedInUser!.customCategories.indexOf(oldItem);
        if (index != -1) _loggedInUser!.customCategories[index] = newItem;
      } else if (oldItem is Appointment && newItem is Appointment) {
        final index = _loggedInUser!.calendar.appointments.indexOf(oldItem);
        if (index != -1) _loggedInUser!.calendar.appointments[index] = newItem;
      } else if (oldItem is Person && newItem is Person) {
        final index = _loggedInUser!.contacts.indexOf(oldItem);
        if (index != -1) _loggedInUser!.contacts[index] = newItem;
      } else if (oldItem is Habit && newItem is Habit) {
        final index = _loggedInUser!.habits.indexOf(oldItem);
        if (index != -1) _loggedInUser!.habits[index] = newItem;
      } else if (oldItem is TaskItem && newItem is TaskItem) {
        final index = _loggedInUser!.tasks.indexOf(oldItem);
        if (index != -1) _loggedInUser!.tasks[index] = newItem;
      } else if (oldItem is Bill && newItem is Bill) {
        final index = _loggedInUser!.bills.indexOf(oldItem);
        if (index != -1) _loggedInUser!.bills[index] = newItem;
      }
      _saveUsers();
      notifyListeners();
    }
  }

  // PROFILE MANAGEMENT
  void updateProfile(Person newProfile) {
    if (_loggedInUser != null) {
      _loggedInUser!.person = newProfile;
      _saveUsers();
      notifyListeners();
    }
  }
}
