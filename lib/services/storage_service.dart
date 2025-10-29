import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:myapp/models/user.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/app_state.json');
  }

  Future<List<User>> readUsers() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return json.map((e) => User.fromJson(e)).toList();
    } catch (e) {
      // If the file doesn't exist or is invalid, return an empty list
      return [];
    }
  }

  Future<File> saveUsers(List<User> users) async {
    final file = await _localFile;
    final json = users.map((e) => e.toJson()).toList();
    return file.writeAsString(jsonEncode(json));
  }
}
