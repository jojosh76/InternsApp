import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Mode clair par défaut
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Informe l'application de redessiner les widgets
  }
}