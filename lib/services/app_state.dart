import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/calendar/tracked_activity.dart';
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

  User? get loggedInUser => _loggedInUser;
  List<User> get users => _users;
  SelectableActivity? get currentlyTracking => _currentlyTracking;
  DateTime? get trackingStartTime => _trackingStartTime;
  bool get toastNotificationsEnabled => _toastNotificationsEnabled;

  AppState() {
    _loadUsers();
  }

  void setToastNotificationsEnabled(bool value) {
    _toastNotificationsEnabled = value;
    // For a production app this would be saved to storage/SharedPreferences.
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
        fullName: 'Test User',
        dateOfBirth: DateTime(1995, 5, 23),
        email: 'test@debug.com',
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
      stopTracking(); // Stop previous activity before starting a new one
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
  }

  // BILL MANAGEMENT
  void addBill(Bill bill) {
    if (_loggedInUser != null) {
      _loggedInUser!.bills.add(bill);
      _saveUsers();
      notifyListeners();
    }
  }

  void updateBill(Bill oldBill, Bill newBill) {
    if (_loggedInUser != null) {
      final index = _loggedInUser!.bills.indexOf(oldBill);
      if (index != -1) {
        _loggedInUser!.bills[index] = newBill;
        _saveUsers();
        notifyListeners();
      }
    }
  }

  void deleteBill(Bill bill) {
    if (_loggedInUser != null) {
      _loggedInUser!.bills.remove(bill);
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
      switch (T) {
        case Category:
          final index = _loggedInUser!.customCategories.indexOf(
            oldItem as Category,
          );
          if (index != -1) {
            _loggedInUser!.customCategories[index] = newItem as Category;
          }
          break;
        case Appointment:
          final index = _loggedInUser!.calendar.appointments.indexOf(
            oldItem as Appointment,
          );
          if (index != -1) {
            _loggedInUser!.calendar.appointments[index] =
                newItem as Appointment;
          }
          break;
        case Person:
          final index = _loggedInUser!.contacts.indexOf(oldItem as Person);
          if (index != -1) {
            _loggedInUser!.contacts[index] = newItem as Person;
          }
          break;
      }
      _saveUsers();
      notifyListeners();
    }

    //   void addAppointment(Appointment appointment) {
    //     if (_loggedInUser != null) {
    //       _loggedInUser!.calendar.appointments.add(appointment);
    //       _saveUsers();
    //       notifyListeners();
    //     }
    //   }

    //   void deleteAppointment(Appointment appointment) {
    //     if (_loggedInUser != null) {
    //       _loggedInUser!.calendar.appointments.remove(appointment);
    //       _saveUsers();
    //       notifyListeners();
    //     }
    //   }

    //   void updateAppointment(
    //     Appointment oldAppointment,
    //     Appointment newAppointment,
    //   ) {
    //     if (_loggedInUser != null) {
    //       final index = _loggedInUser!.calendar.appointments.indexOf(
    //         oldAppointment,
    //       );
    //       if (index != -1) {
    //         _loggedInUser!.calendar.appointments[index] = newAppointment;
    //         _saveUsers();
    //         notifyListeners();
    //       }
    //       _saveUsers();
    //       notifyListeners();
    //     }
    //   }

    //   // PERSON (CONTACT) MANAGEMENT
    //   void addPerson(Person person) {
    //     if (_loggedInUser != null) {
    //       _loggedInUser!.contacts.add(person);

    //       void updatePerson(Person oldPerson, Person newPerson) {
    //         if (_loggedInUser != null) {
    //           final index = _loggedInUser!.contacts.indexOf(oldPerson);
    //           if (index != -1) {
    //             _loggedInUser!.contacts[index] = newPerson;
    //             _saveUsers();
    //             notifyListeners();
    //           }
    //         }
    //       }

    //       void deletePerson(Person person) {
    //         if (_loggedInUser != null) {
    //           _loggedInUser!.contacts.remove(person);
    //           _saveUsers();
    //           notifyListeners();
    //         }
    //       }

    //       // USER PROFILE MANAGEMENT
    //       void updateUserName(String newName) {
    //         if (_loggedInUser != null) {
    //           _loggedInUser!.person = Person(
    //             fullName: newName,
    //             dateOfBirth: _loggedInUser!.person.dateOfBirth,
    //             email: _loggedInUser!.person.email,
    //             nickname: _loggedInUser!.person.nickname,
    //             address: _loggedInUser!.person.address,
    //             profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
    //           );
    //           _saveUsers();
    //           notifyListeners();
    //         }
    //       }

    //       void updateUserEmail(String newEmail) {
    //         if (_loggedInUser != null) {
    //           _loggedInUser!.person = Person(
    //             fullName: _loggedInUser!.person.fullName,
    //             dateOfBirth: _loggedInUser!.person.dateOfBirth,
    //             email: newEmail,
    //             nickname: _loggedInUser!.person.nickname,
    //             address: _loggedInUser!.person.address,
    //             profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
    //           );
    //           _saveUsers();
    //           notifyListeners();
    //         }
    //       }

    //       void updateUserNickname(String newNickname) {
    //         if (_loggedInUser != null) {
    //           _loggedInUser!.person = Person(
    //             fullName: _loggedInUser!.person.fullName,
    //             dateOfBirth: _loggedInUser!.person.dateOfBirth,
    //             email: _loggedInUser!.person.email,
    //             nickname: newNickname,
    //             address: _loggedInUser!.person.address,
    //             profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
    //           );
    //           _saveUsers();
    //           notifyListeners();
    //         }
    //       }

    //       void updateUserAddress(String newAddress) {
    //         if (_loggedInUser != null) {
    //           _loggedInUser!.person = Person(
    //             fullName: _loggedInUser!.person.fullName,
    //             dateOfBirth: _loggedInUser!.person.dateOfBirth,
    //             email: _loggedInUser!.person.email,
    //             nickname: _loggedInUser!.person.nickname,
    //             address: newAddress,
    //             profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
    //           );
    //           _saveUsers();
    //           notifyListeners();
    //         }
    //       }

    //       void updateUserDateOfBirth(DateTime newDateOfBirth) {
    //         if (_loggedInUser != null) {
    //           _loggedInUser!.person = Person(
    //             fullName: _loggedInUser!.person.fullName,
    //             dateOfBirth: newDateOfBirth,
    //             email: _loggedInUser!.person.email,
    //             nickname: _loggedInUser!.person.nickname,
    //             address: _loggedInUser!.person.address,
    //             profilePictureUrl: _loggedInUser!.person.profilePictureUrl,
    //           );
    //           _saveUsers();
    //           notifyListeners();
    //         }
    //       }
    //     }
    //     _saveUsers();
    //     notifyListeners();
    //   }
  }
}
