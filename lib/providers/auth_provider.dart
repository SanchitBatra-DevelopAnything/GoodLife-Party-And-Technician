import 'package:flutter/material.dart';

import '../models/login_context.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../utils/session_status.dart';

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
      await LocalStorageService.saveUserCredentials(
        mobile: mobile,
        areaName: areaName,
      );

      _loginContext = context;

      await syncDeviceToken();
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
      if (_loginContext != null) {
        final isValid = await validateSession();
        if (!isValid) {
          notifyListeners();
          return;
        }

        final token = await NotificationService().getToken();
        if (token != null) {
          await syncDeviceToken(token);
        }
      }
      notifyListeners();
    } catch (_) {
      // ignore cache errors
    }
  }

  Future<void> syncDeviceToken([String? token]) async {
    if (!isLoggedIn || mobile.isEmpty) return;

    final fcmToken = token ?? await NotificationService().getToken();
    if (fcmToken == null) return;

    await authService.updateDeviceToken(mobile, fcmToken);

    final updatedContext = _loginContext!.copyWith(
      distributorDetails:
          _loginContext!.distributorDetails.copyWith(deviceToken: fcmToken),
    );
    _loginContext = updatedContext;
    await LocalStorageService.saveLoginContext(updatedContext);
  }

  Future<bool> validateSession() async {
    if (!isLoggedIn) return false;

    final mobileToCheck = mobile;
    final areaToCheck = areaName.isNotEmpty ? areaName : area;

    if (mobileToCheck.isEmpty || areaToCheck.isEmpty) {
      await forceLogout();
      return false;
    }

    final status = await authService.validateUserSession(
      mobile: mobileToCheck,
      areaName: areaToCheck,
    );

    if (status == SessionStatus.invalid) {
      await forceLogout();
      return false;
    }

    return true;
  }

  Future<void> forceLogout() async {
    _loginContext = null;
    await LocalStorageService.clearLoginContext();
    await LocalStorageService.clearUserCredentials();
    notifyListeners();
  }

  Future<void> logout() async {
    _loginContext = null;

    await LocalStorageService.clearLoginContext();
    await LocalStorageService.clearUserCredentials();

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