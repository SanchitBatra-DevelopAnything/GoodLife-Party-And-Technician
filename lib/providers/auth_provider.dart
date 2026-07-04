import 'package:flutter/material.dart';

import '../models/login_context.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService = AuthService();

  bool isLoading = false;

  LoginContext? _loginContext;

  LoginContext? get loginContext => _loginContext;

  bool get isLoggedIn => _loginContext != null;

  Future<void> login({
    required String mobile,
    required String areaName,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final context = await authService.login(
        mobile: mobile,
        areaName: areaName,
      );
      print("Context Received");
      await LocalStorageService.saveLoginContext(context);

      _loginContext = context;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedContext() async {
    try {
      _loginContext = await LocalStorageService.getLoginContext();
      notifyListeners();
    } catch (_) {
      // ignore cache errors
    }
  }



  Future<void> logout() async {
    _loginContext = null;

    await LocalStorageService.clearLoginContext();

    notifyListeners();
  }

  // -----------------------------
  // Convenience Getters
  // -----------------------------

  DistributorDetails? get distributorDetails =>
      _loginContext?.distributorDetails;

  AreaDetails? get areaDetails =>
      _loginContext?.areaDetails;

  String get distributorName =>
      distributorDetails?.distributorName ?? '';

  String get mobile =>
      distributorDetails?.contact ?? '';

  String get area =>
      distributorDetails?.area ?? '';

  bool get allowPayLater =>
      distributorDetails?.allowPayLater ?? false;

  List<String> get machineIds =>
      distributorDetails?.machineIds ?? [];

  String get deviceToken =>
      distributorDetails?.deviceToken ?? '';

  double get amcPrice =>
      areaDetails?.amcPrice ?? 0;

  int get amcServices =>
      areaDetails?.amcServices ?? 0;

  double get freightPercentage =>
      areaDetails?.freightPercentage ?? 0;

  String get areaName =>
      areaDetails?.areaName ?? '';

  int get salesContact =>
      areaDetails?.salesContact ?? 0;

  String get salesPerson =>
      areaDetails?.salesPerson ?? '';
}