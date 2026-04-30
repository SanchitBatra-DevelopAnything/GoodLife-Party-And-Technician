import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:goodlife_party/screens/signup/signup.dart';

import '../screens/home_screen.dart';
// import '../screens/login_screen.dart';
// import '../screens/profile_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  const RouteGenerator._(); // Prevent instantiation

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _buildRoute(const HomeScreen());

      case AppRoutes.signup:
        return _buildRoute(const SignupScreen());

      // case AppRoutes.profile:
      //   return _buildRoute(const ProfileScreen());

      default:
        return _errorRoute();
    }
  }

  /// 🔹 Platform-aware route builder
  static Route<dynamic> _buildRoute(Widget child) {
    if (Platform.isIOS) {
      return CupertinoPageRoute(
        builder: (_) => child,
      );
    } else {
      return MaterialPageRoute(
        builder: (_) => child,
      );
    }
  }

  /// 🔹 Fallback route (safe & clean)
  static Route<dynamic> _errorRoute() {
    return _buildRoute(
      const Scaffold(
        body: Center(
          child: Text(
            'Page not found',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

//Navigator.pushReplacementNamed(context, AppRoutes.home);