import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale locale = const Locale('en');

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code');

    if (code != null) {
      locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(String code) async {
    locale = Locale(code);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);

    notifyListeners();
  }
}