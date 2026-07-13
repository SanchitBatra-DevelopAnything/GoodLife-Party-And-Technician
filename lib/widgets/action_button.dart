import 'package:flutter/material.dart';
import 'package:goodlife_party/l10n/app_localizations.dart';
import 'package:goodlife_party/providers/auth_provider.dart';
import 'package:goodlife_party/providers/technician_auth_provider.dart';
import 'package:goodlife_party/routes/app_routes.dart';
import 'package:goodlife_party/screens/home_screen.dart';
import 'package:goodlife_party/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class ActionButtons extends StatefulWidget {
  final UserRole? selectedRole;
  final bool isIOS;

  const ActionButtons({
    super.key,
    required this.selectedRole,
    required this.isIOS,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _isValidating = false;

  Future<void> _handleLoginTap() async {
    if (widget.selectedRole == null || _isValidating) return;

    setState(() => _isValidating = true);

    try {
      if (widget.selectedRole == UserRole.technician) {
        final technicianAuth = context.read<TechnicianAuthProvider>();
        if (technicianAuth.isLoggedIn) {
          final isValid = await technicianAuth.validateSession();
          if (!mounted) return;

          if (isValid) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.technicianServiceRequests,
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Your technician account is no longer active. Please log in again.',
                ),
              ),
            );
            Navigator.pushNamed(context, AppRoutes.technicianLogin);
          }
          return;
        }

        Navigator.pushNamed(context, AppRoutes.technicianLogin);
        return;
      }

      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        final isValid = await auth.validateSession();
        if (!mounted) return;

        if (isValid) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.inventory,
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Your account is no longer active. Please log in again.',
              ),
            ),
          );
          Navigator.pushNamed(context, AppRoutes.login);
        }
        return;
      }

      Navigator.pushNamed(context, AppRoutes.login);
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.selectedRole == null) return const SizedBox();

    final loginButton = PrimaryButton(
      text: _isValidating ? 'Checking...' : l10n.login,
      onPressed: _isValidating ? null : _handleLoginTap,
      isIOS: widget.isIOS,
    );

    final signupButton = SecondaryButton(
      text: l10n.signUp,
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
      isIOS: widget.isIOS,
    );

    return Column(
      children: [
        loginButton,
        const SizedBox(height: 12),

        /// Only for USER
        if (widget.selectedRole == UserRole.user) signupButton,
      ],
    );
  }
}
