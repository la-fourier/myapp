import 'package:flutter/foundation.dart';

class LoadingService {
  factory LoadingService() {
    return _instance;
  }

  LoadingService._internal();

  static final LoadingService _instance = LoadingService._internal();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  void show() {
    isLoading.value = true;
  }

  void hide() {
    isLoading.value = false;
  }
}
