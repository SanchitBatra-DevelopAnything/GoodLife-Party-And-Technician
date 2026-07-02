import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/screens/cart/cart_screen.dart';
import 'package:goodlife_party/screens/categories_screen.dart';
import 'package:goodlife_party/screens/custom_order_screen.dart';
import 'package:goodlife_party/screens/home_screen.dart';
import 'package:goodlife_party/screens/inventory_screen.dart';
import 'package:goodlife_party/screens/items_screen.dart';
import 'package:goodlife_party/screens/login/login_screen.dart';
import 'package:goodlife_party/screens/my_orders_spare_parts.dart';
import 'package:goodlife_party/screens/profile_screen.dart';
import 'package:goodlife_party/screens/sales_screen.dart';
import 'package:goodlife_party/screens/signup/signup.dart';
import 'package:goodlife_party/screens/spare_part_order_options.dart';

import 'package:goodlife_party/models/service_request_model.dart';
import 'package:goodlife_party/screens/my_service_requests_screen.dart';
import 'package:goodlife_party/screens/service_request_details_screen.dart';
import 'package:goodlife_party/screens/service_request_form_screen.dart';

import 'app_routes.dart';

class RouteGenerator {
  const RouteGenerator._();

  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case AppRoutes.home:
        return _buildRoute(const HomeScreen());
      
      case AppRoutes.customOrder:
        return _buildRoute(const CustomOrderScreen());

      case AppRoutes.inventory:
        return _buildRoute(const InventoryScreen());

      case AppRoutes.sparePartOptions:
        return _buildRoute(const SparePartsOrderOptionsScreen());

      case AppRoutes.sales:
        return _buildRoute(const SalesScreen());

      case AppRoutes.signup:
        return _buildRoute(const SignupScreen());

      case AppRoutes.login:
        return _buildRoute(const LoginScreen());

      case AppRoutes.profile:
        return _buildRoute(const ProfileScreen());

      case AppRoutes.categories:
        return _buildRoute(const CategoriesScreen());

      case AppRoutes.cart:
        return _buildRoute(const CartScreen());
      
      case AppRoutes.myOrdersSpareParts:
        return _buildRoute(const SparePartsOrdersScreen());

      case AppRoutes.serviceRequestForm:
        return _buildRoute(const ServiceRequestFormScreen());

      case AppRoutes.myServiceRequests:
        return _buildRoute(const MyServiceRequestsScreen());

      case AppRoutes.serviceRequestDetails:
        final req = settings.arguments as ServiceRequestModel;
        return _buildRoute(
          ServiceRequestDetailsScreen(request: req),
        );

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