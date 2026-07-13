import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_context.dart';
import '../models/technician_login_context.dart';

class SavedUserCredentials {
  final String mobile;
  final String areaName;

  const SavedUserCredentials({
    required this.mobile,
    required this.areaName,
  });
}

class SavedTechnicianCredentials {
  final String mobile;
  final String password;

  const SavedTechnicianCredentials({
    required this.mobile,
    required this.password,
  });
}

class LocalStorageService {
  static const String loginContextKey = "login_context";
  static const String technicianLoginContextKey = "technician_login_context";
  static const String mobileKey = "mobile";
  static const String areaKey = "area";
  static const String savedUserMobileKey = "saved_user_mobile";
  static const String savedUserAreaKey = "saved_user_area";
  static const String savedTechnicianMobileKey = "saved_technician_mobile";
  static const String savedTechnicianPasswordKey = "saved_technician_password";

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

    await prefs.setString(
      'logged_in_user',
      jsonEncode(context.distributorDetails.toJson()),
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
    await prefs.remove('logged_in_user');
  }

  static Future<void> saveTechnicianLoginContext(
    TechnicianLoginContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      technicianLoginContextKey,
      jsonEncode(context.toJson()),
    );
  }

  static Future<TechnicianLoginContext?> getTechnicianLoginContext() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(technicianLoginContextKey);
    if (data == null) return null;
    return TechnicianLoginContext.fromJson(jsonDecode(data));
  }

  static Future<void> clearTechnicianLoginContext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(technicianLoginContextKey);
  }

  static Future<void> saveUserCredentials({
    required String mobile,
    required String areaName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(savedUserMobileKey, mobile);
    await prefs.setString(savedUserAreaKey, areaName);
  }

  static Future<SavedUserCredentials?> getUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString(savedUserMobileKey);
    final areaName = prefs.getString(savedUserAreaKey);

    if (mobile == null || areaName == null) return null;

    return SavedUserCredentials(mobile: mobile, areaName: areaName);
  }

  static Future<void> clearUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(savedUserMobileKey);
    await prefs.remove(savedUserAreaKey);
  }

  static Future<void> saveTechnicianCredentials({
    required String mobile,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(savedTechnicianMobileKey, mobile);
    await prefs.setString(savedTechnicianPasswordKey, password);
  }

  static Future<SavedTechnicianCredentials?> getTechnicianCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString(savedTechnicianMobileKey);
    final password = prefs.getString(savedTechnicianPasswordKey);

    if (mobile == null || password == null) return null;

    return SavedTechnicianCredentials(mobile: mobile, password: password);
  }

  static Future<void> clearTechnicianCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(savedTechnicianMobileKey);
    await prefs.remove(savedTechnicianPasswordKey);
  }
}