import 'package:flutter/foundation.dart';

class ChangeTheme extends ChangeNotifier {
  bool _isDark = false;
  //getter
  get getTheme => _isDark;

  doDark() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
