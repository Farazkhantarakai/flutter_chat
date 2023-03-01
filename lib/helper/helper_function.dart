import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String userLoggedInKey = 'USERLOGEDIN';
  static String userEmailKey = 'USEREMAIL';
  static String userNameKey = 'USERNAME';

  static Future<bool?> saveUserLoggedInStatus(bool isUserLogedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLogedIn);
  }

  static Future<bool?> saveUserNameSf(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print(userName);
    }
    return await sf.setString(userNameKey, userName);
  }

  static Future<bool?> saveUserEmailSf(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print(userEmail);
    }
    return await sf.setString(userEmailKey, userEmail);
  }

  static Future<bool?> getUserLogedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserName() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }
}
