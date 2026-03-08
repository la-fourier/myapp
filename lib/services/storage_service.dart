import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myapp/models/user.dart';

class StorageService {
  static const _usersKey = 'users';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/app_state.json');
  }

  Future<List<User>> readUsers() async {
    if (kIsWeb) {
      return _readUsersFromWeb();
    } else {
      return _readUsersFromFile();
    }
  }

  Future<void> saveUsers(List<User> users) async {
    if (kIsWeb) {
      await _saveUsersToWeb(users);
    } else {
      await _saveUsersToFile(users);
    }
  }

  Future<void> saveLoggedInUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInUser', email);
  }

  Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedInUser');
  }

  Future<List<User>> _readUsersFromFile() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((e) => User.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) {
      // If the file doesn't exist or is invalid, return an empty list
      return [];
    }
  }

  Future<File> _saveUsersToFile(List<User> users) async {
    final file = await _localFile;
    final json = users.map((e) => e.toJson()).toList();
    return file.writeAsString(jsonEncode(json));
  }

  Future<List<User>> _readUsersFromWeb() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contents = prefs.getString(_usersKey);
      if (contents == null) {
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((e) => User.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveUsersToWeb(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final json = users.map((e) => e.toJson()).toList();
    await prefs.setString(_usersKey, jsonEncode(json));
  }
}
