

import 'package:flutter/material.dart';

import '../Utils/app_themes.dart';

class ThemeManager with ChangeNotifier {
  ThemeData _themeData;

  ThemeManager(this._themeData);

  ThemeData get themeData => _themeData;

  void setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData.brightness == Brightness.dark) {
      setTheme(AppThemes.lightTheme);
    } else {
      setTheme(AppThemes.darkTheme);
    }
  }
}
