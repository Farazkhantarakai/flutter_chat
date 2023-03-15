import 'package:shared_preferences/shared_preferences.dart';

class MyThemePreferences {
  static const theme_key = "theme_key";

  setTheme(bool value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool(theme_key, value);
  }

  getTheme() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(theme_key) ?? false;
  }
}
