import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // 🔴 Brand Colors
  static const Color primaryRed = Color(0xFFC62828);
  static const Color darkRed = Color(0xFF8E0000);
  static const Color lightRed = Color(0xFFFF5F52);

  // ⚪ Neutrals
  static const Color white = Colors.white;
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkText = Color(0xFF212121);

  /// 🌐 Get platform theme
  static ThemeData getMaterialTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: lightGrey,

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryRed,
        onPrimary: white,
        secondary: lightRed,
        onSecondary: white,
        error: Colors.red,
        onError: white,
        background: white,
        onBackground: darkText,
        surface: white,
        onSurface: darkText,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        bodyMedium: TextStyle(fontSize: 16, color: darkText),
      ),

      cardTheme: CardThemeData(
        color: white,
        elevation: 1.5,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// 🍎 Cupertino Theme
  static CupertinoThemeData getCupertinoTheme() {
    return const CupertinoThemeData(
      primaryColor: primaryRed,
      scaffoldBackgroundColor: lightGrey,
      barBackgroundColor: white,
      textTheme: CupertinoTextThemeData(
        navTitleTextStyle: TextStyle(
          color: darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
