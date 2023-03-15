import 'package:flutter/foundation.dart';
import '../helper/mythemepreferences.dart';

class ChangeTheme extends ChangeNotifier {
  bool _isDark = false;

  late MyThemePreferences _preferences;
  //getter
  get getTheme => _isDark;

  ChangeTheme() {
    _isDark = false;
    _preferences = MyThemePreferences();
    getPreference();
  }

  doDark() {
    _isDark = !_isDark;
    // this will save the data
    _preferences.setTheme(_isDark);
    notifyListeners();
  }

  getPreference() async {
    _isDark = await _preferences.getTheme();
    notifyListeners();
  }
}
