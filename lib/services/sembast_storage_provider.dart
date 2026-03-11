import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'package:myapp/models/user.dart';

class SembastStorageProvider {
  static const String _dbName = 'app.db';
  static const String _usersStoreName = 'users';
  static const _loggedInUserKey = 'loggedInUser';

  late Database _db;
  late StoreRef<String, Map<String, dynamic>> _usersStore;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    await appDir.create(recursive: true);
    final dbPath = join(appDir.path, _dbName);
    _db = await databaseFactoryIo.openDatabase(dbPath);
    _usersStore = stringMapStoreFactory.store(_usersStoreName);
  }

  Future<List<User>> readUsers() async {
    final records = await _usersStore.find(_db);
    return records.map((snapshot) {
      final user = User.fromJson(snapshot.value);
      return user;
    }).toList();
  }

  Future<void> saveUsers(List<User> users) async {
    await _usersStore.delete(_db); // Clear old users
    for (final user in users) {
      await _usersStore.record(user.person.email!).put(_db, user.toJson());
    }
  }

  Future<void> saveLoggedInUser(String email) async {
    // In sembast, we can store simple key-value pairs in the default store
    await StoreRef.main().record(_loggedInUserKey).put(_db, email);
  }

  Future<String?> getLoggedInUser() async {
    final email = await StoreRef.main().record(_loggedInUserKey).get(_db) as String?;
    return email;
  }
}
