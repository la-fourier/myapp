abstract class StorageProvider {
  Future<void> init();

  Future<T?> get<T>(String key);

  Future<List<T>> getAll<T>();

  Future<void> put<T>(String key, T value);

  Future<void> delete<T>(String key);

  Future<void> clear();
}
