import 'package:flutter/material.dart';

import '../models/technician_login_context.dart';
import '../models/technician_model.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../services/technician_auth_service.dart';
import '../utils/session_status.dart';

class TechnicianAuthProvider extends ChangeNotifier {
  final TechnicianAuthService _authService = TechnicianAuthService();

  bool isLoading = false;
  TechnicianLoginContext? _loginContext;

  TechnicianLoginContext? get loginContext => _loginContext;
  bool get isLoggedIn => _loginContext != null;

  TechnicianModel? get technician => _loginContext?.technician;
  String get technicianId => technician?.technicianId ?? '';
  String get name => technician?.name ?? '';
  String get phone => technician?.phone ?? '';
  String? get photoUrl => technician?.photoUrl;

  Future<void> _syncDeviceToken([String? token]) async {
    if (technicianId.isEmpty) return;

    final fcmToken = token ?? await NotificationService().getToken();
    if (fcmToken != null) {
      await _authService.updateDeviceToken(
        technicianId: technicianId,
        token: fcmToken,
      );
    }
  }

  Future<void> syncDeviceToken([String? token]) => _syncDeviceToken(token);

  Future<void> login({
    required String mobile,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final context = await _authService.login(
        mobile: mobile,
        password: password,
      );
      await LocalStorageService.saveTechnicianLoginContext(context);
      await LocalStorageService.saveTechnicianCredentials(
        mobile: mobile,
        password: password,
      );
      _loginContext = context;

      await _syncDeviceToken();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedContext() async {
    try {
      _loginContext =
          await LocalStorageService.getTechnicianLoginContext();
      if (_loginContext != null) {
        final isValid = await validateSession();
        if (!isValid) {
          notifyListeners();
          return;
        }

        await _syncDeviceToken();
      }
      notifyListeners();
    } catch (_) {
      // ignore cache errors
    }
  }

  Future<bool> validateSession() async {
    if (!isLoggedIn) return false;

    if (technicianId.isEmpty) {
      await forceLogout();
      return false;
    }

    final status = await _authService.validateTechnicianSession(
      technicianId: technicianId,
    );

    if (status == SessionStatus.invalid) {
      await forceLogout();
      return false;
    }

    return true;
  }

  Future<void> forceLogout() async {
    _loginContext = null;
    await LocalStorageService.clearTechnicianLoginContext();
    await LocalStorageService.clearTechnicianCredentials();
    notifyListeners();
  }

  Future<void> logout() async {
    _loginContext = null;
    await LocalStorageService.clearTechnicianLoginContext();
    await LocalStorageService.clearTechnicianCredentials();
    notifyListeners();
  }
}
