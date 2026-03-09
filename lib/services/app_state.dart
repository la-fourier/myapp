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
import 'package:myapp/services/travel_time_service.dart';

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
  bool _isInitialized = false;

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
  bool get isInitialized => _isInitialized;
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

    _isInitialized = true;
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
          frequencyTimes: 7,
          frequencyPeriod: FrequencyPeriod.week,
          priority: 5,
        ),
        Habit(
          id: 'h2',
          name: 'Read Book',
          frequencyTimes: 5,
          frequencyPeriod: FrequencyPeriod.week,
          preferredStartTime: const TimeOfDay(hour: 19, minute: 0),
          preferredEndTime: const TimeOfDay(hour: 22, minute: 0),
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
      (e) => SelectableActivity(name: e.title, category: e.category, original: e),
    );

    final fromTasks = _loggedInUser!.tasks.expand((rootItem) {
      List<TaskItem> allItems = [];
      void collect(TaskItem item) {
        allItems.add(item);
        if (item is Project) {
          for (var child in item.children) {
            collect(child);
          }
        }
      }
      collect(rootItem);
      return allItems;
    }).map((t) {
      final category = _loggedInUser!.customCategories.firstWhereOrNull((c) => c.name == t.categoryId) 
          ?? Category(name: 'Uncategorized', color: Colors.grey);
      return SelectableActivity(name: t.name, category: category, original: t);
    });

    return [...fromAppointments, ...fromTasks];
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
      String? taskId;
      if (_currentlyTracking!.original is TaskItem) {
        taskId = (_currentlyTracking!.original as TaskItem).id;
      }

      final trackedActivity = TrackedActivity(
        name: _currentlyTracking!.name,
        category: _currentlyTracking!.category,
        startTime: _trackingStartTime!,
        endTime: DateTime.now(),
        taskId: taskId,
      );
      _loggedInUser!.calendar.trackedActivities.add(trackedActivity);
      
      // If it was a task, we might want to store the session id back in the task
      // depending on how the model is designed. Currently the task has sessionIds.
      if (taskId != null) {
        _addSessionToTask(taskId, trackedActivity.id);
      }

      _currentlyTracking = null;
      _trackingStartTime = null;
      _saveUsers();
      notifyListeners();
    }
  }

  void _addSessionToTask(String taskId, String sessionId) {
    if (_loggedInUser == null) return;
    
    bool found = false;
    void search(List<TaskItem> items) {
      for (var i = 0; i < items.length; i++) {
        var item = items[i];
        if (item.id == taskId && item is Task) {
          final updatedTask = Task(
            id: item.id,
            name: item.name,
            description: item.description,
            contactUids: item.contactUids,
            categoryId: item.categoryId,
            location: item.location,
            address: item.address,
            deadline: item.deadline,
            priority: item.priority,
            froggyness: item.froggyness,
            duration: item.duration,
            sessionIds: [...item.sessionIds, sessionId],
          );
          items[i] = updatedTask;
          found = true;
          return;
        } else if (item is Project) {
          search(item.children);
          if (found) return;
        }
      }
    }
    search(_loggedInUser!.tasks);
  }

  Duration getWorkedDuration(TaskItem item) {
    if (_loggedInUser == null) return Duration.zero;
    if (item is Task) {
      return _loggedInUser!.calendar.trackedActivities
          .where((a) => a.taskId == item.id)
          .fold(Duration.zero, (sum, a) => sum + a.duration);
    } else if (item is Project) {
      return item.children.fold(Duration.zero, (sum, child) => sum + getWorkedDuration(child));
    }
    return Duration.zero;
  }

  double getTaskProgress(TaskItem item) {
    final worked = getWorkedDuration(item);
    final total = item.duration;
    if (total.inMinutes <= 0) return 1.0;
    return (worked.inMinutes / total.inMinutes).clamp(0.0, 1.0);
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
      _onDataChanged();
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
      _onDataChanged();
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
      _onDataChanged();
    }
  }

  // TRAVEL VALIDATION
  List<String> getTravelConflicts() {
    if (_loggedInUser == null) return [];
    
    final appointments = List<Appointment>.from(_loggedInUser!.calendar.appointments);
    appointments.sort((a, b) => a.start.compareTo(b.start));

    final travelService = TravelTimeService();
    final conflicts = <String>[];

    for (int i = 0; i < appointments.length - 1; i++) {
      final first = appointments[i];
      final second = appointments[i + 1];

      // Only check same day
      if (first.start.year == second.start.year &&
          first.start.month == second.start.month &&
          first.start.day == second.start.day) {
        
        final msg = travelService.getConflictMessage(first, second);
        if (msg != null) {
          conflicts.add(msg);
        }
      }
    }
    return conflicts;
  }

  void _onDataChanged() {
    _saveUsers();
    final conflicts = getTravelConflicts();
    for (final conflict in conflicts) {
      // Just a toast for now as per "automatically check"
      // In a real app we might want a persistent warning bar
      debugPrint('Travel Conflict: $conflict');
    }
    notifyListeners();
  }

  void updateProfile(Person newProfile) {
    if (_loggedInUser != null) {
      _loggedInUser!.person = newProfile;
      _onDataChanged();
    }
  }
}
