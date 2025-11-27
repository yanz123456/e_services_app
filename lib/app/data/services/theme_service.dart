import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  ThemeService();

  static const _storageKey = 'theme_mode';
  final _box = GetStorage();
  final Rx<ThemeMode> _themeMode = ThemeMode.light.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  Future<ThemeService> init() async {
    final stored = _box.read<String>(_storageKey);
    if (stored == 'dark') {
      _themeMode.value = ThemeMode.dark;
    } else {
      _themeMode.value = ThemeMode.light;
    }
    return this;
  }

  void toggleTheme(bool isDark) => setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _box.write(_storageKey, mode == ThemeMode.dark ? 'dark' : 'light');
    Get.changeThemeMode(mode);
  }

  Rx<ThemeMode> get rxThemeMode => _themeMode;
}
