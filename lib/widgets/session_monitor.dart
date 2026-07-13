import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/outstanding_balance_provider.dart';
import '../providers/technician_auth_provider.dart';
import '../routes/app_routes.dart';
import '../services/notification_service.dart';

class SessionMonitor extends StatefulWidget {
  final Widget child;

  const SessionMonitor({
    super.key,
    required this.child,
  });

  @override
  State<SessionMonitor> createState() => _SessionMonitorState();
}

class _SessionMonitorState extends State<SessionMonitor>
    with WidgetsBindingObserver {
  Timer? _periodicValidationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicValidation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicValidationTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _validateActiveSessions();
    }
  }

  void _startPeriodicValidation() {
    _periodicValidationTimer?.cancel();
    _periodicValidationTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _validateActiveSessions(),
    );
  }

  Future<void> _validateActiveSessions() async {
    final context = NotificationService.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      final isValid = await auth.validateSession();
      if (!isValid && context.mounted) {
        _redirectAfterForcedLogout(
          context,
          message: 'Your account is no longer active. Please log in again.',
        );
        return;
      }
    }

    final technicianAuth = context.read<TechnicianAuthProvider>();
    if (technicianAuth.isLoggedIn) {
      final isValid = await technicianAuth.validateSession();
      if (!isValid && context.mounted) {
        _redirectAfterForcedLogout(
          context,
          message:
              'Your technician account is no longer active. Please log in again.',
        );
      }
    }
  }

  void _redirectAfterForcedLogout(
    BuildContext context, {
    required String message,
  }) {
    // Stop the outstanding balance listener so it doesn't leak after force-logout
    context.read<OutstandingBalanceProvider>().stopListening();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
