import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_context.dart';

class LocalStorageService {
  static const String loginContextKey = "login_context";
  static const String mobileKey = "mobile";
  static const String areaKey = "area";

  static Future<void> saveLoginContext(
    LoginContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      loginContextKey,
      jsonEncode(context.toJson()),
    );

    await prefs.setString(
      mobileKey,
      context.distributorDetails.contact,
    );

    await prefs.setString(
      areaKey,
      context.distributorDetails.area,
    );
  }

  static Future<LoginContext?> getLoginContext() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(loginContextKey);

    if (data == null) return null;

    return LoginContext.fromJson(
      jsonDecode(data),
    );
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(mobileKey);
  }

  static Future<String?> getArea() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(areaKey);
  }

  static Future<void> clearLoginContext() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(loginContextKey);
    await prefs.remove(mobileKey);
    await prefs.remove(areaKey);
  }
}