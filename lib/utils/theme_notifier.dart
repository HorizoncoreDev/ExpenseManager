import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleThemeMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    notifyListeners();
  }

  ThemeData _themeData = ThemeData.dark();

  ThemeData getTheme() => _themeData;
  final darkTheme = ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      brightness: Brightness.dark,
      backgroundColor: Colors.black87,
      hintColor: Colors.white,
      cardColor: const Color(0xff30302d),
      dividerColor: const Color(0xff30302d),
      canvasColor: Colors.blue,
      disabledColor: Colors.amberAccent.shade100,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xff30302d),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white60,
      ));

  final lightTheme = ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      brightness: Brightness.light,
      backgroundColor: Colors.white60,
      hintColor: Colors.black,
      disabledColor: Colors.amberAccent.shade400,
      canvasColor: const Color(0xffdadae0),
      cardColor: const Color(0xffe4e5e9),
      dividerColor: const Color(0xffe4e5e9),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black87));

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((value) {
      var themeMode = value ?? 'dark';
      if (themeMode == 'light') {
        _themeData = lightTheme;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}

class StorageManager {
  static void saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) {
      prefs.setInt(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else {
      print("Invalid Type");
    }
  }

  static Future<dynamic> readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic obj = prefs.get(key);
    return obj;
  }

  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
