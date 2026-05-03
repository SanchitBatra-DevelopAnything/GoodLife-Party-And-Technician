import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService = AuthService();

  bool isLoading = false;
  UserModel? user;

  Future<void> login({
  required String mobile,
  required String areaName,
}) async {
  try {
    isLoading = true;
    notifyListeners();

    final loggedInUser = await authService.login(
      mobile: mobile,
      areaName: areaName,
    );

    await LocalStorageService.saveUser(loggedInUser);

    user = loggedInUser;
  } catch (e) {
    // ✅ important: rethrow so UI can handle it
    throw Exception("Login failed");
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
}