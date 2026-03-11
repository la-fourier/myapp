import 'package:myapp/models/user.dart';
import 'package:myapp/services/legacy_storage_provider.dart';
import 'package:myapp/services/sembast_storage_provider.dart';

enum StorageType { legacy, sembast, github }

class StorageService {
  late dynamic _activeProvider;
  final LegacyStorageProvider _legacyProvider = LegacyStorageProvider();
  final SembastStorageProvider _sembastProvider = SembastStorageProvider();

  Future<void> init(StorageType type) async {
    switch (type) {
      case StorageType.legacy:
        _activeProvider = _legacyProvider;
        break;
      case StorageType.sembast:
        _activeProvider = _sembastProvider;
        await _sembastProvider.init();
        break;
    }
  }

  Future<List<User>> readUsers() async {
    return _activeProvider.readUsers();
  }

  Future<void> saveUsers(List<User> users) async {
    await _activeProvider.saveUsers(users);
  }

  Future<void> saveLoggedInUser(String email) async {
    await _activeProvider.saveLoggedInUser(email);
  }

  Future<String?> getLoggedInUser() async {
    return _activeProvider.getLoggedInUser();
  }
}
