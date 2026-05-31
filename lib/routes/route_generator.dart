import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/screens/cart/cart_screen.dart';
import 'package:goodlife_party/screens/categories_screen.dart';
import 'package:goodlife_party/screens/home_screen.dart';
import 'package:goodlife_party/screens/inventory_screen.dart';
import 'package:goodlife_party/screens/items_screen.dart';
import 'package:goodlife_party/screens/login/login_screen.dart';
import 'package:goodlife_party/screens/sales_screen.dart';
import 'package:goodlife_party/screens/signup/signup.dart';

import 'app_routes.dart';

class RouteGenerator {
  const RouteGenerator._();

  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case AppRoutes.home:
        return _buildRoute(const HomeScreen());

      case AppRoutes.inventory:
        return _buildRoute(const InventoryScreen());

      case AppRoutes.sales:
        return _buildRoute(const SalesScreen());

      case AppRoutes.signup:
        return _buildRoute(const SignupScreen());

      case AppRoutes.login:
        return _buildRoute(const LoginScreen());

      case AppRoutes.categories:
        return _buildRoute(const CategoriesScreen());

      case AppRoutes.cart:
        return _buildRoute(const CartScreen());

      case AppRoutes.items:
        final args =
            settings.arguments as Map<String, dynamic>;

        return _buildRoute(
          ItemsScreen(
            categoryId: args['categoryId'],
            categoryName: args['categoryName'],
          ),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _buildRoute(
    Widget child,
  ) {
    if (Platform.isIOS) {
      return CupertinoPageRoute(
        builder: (_) => child,
      );
    }

    return MaterialPageRoute(
      builder: (_) => child,
    );
  }

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