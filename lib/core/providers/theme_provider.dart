import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// 判断当前是否为暗黑模式
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// 切换主题，如果传入 isDark，则设置为指定主题，否则取反
  void toggleTheme([bool? isDark]) {
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      // 取反切换
      _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    }
    notifyListeners();
  }
}
