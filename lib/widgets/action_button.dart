import 'package:flutter/material.dart';
import 'package:goodlife_party/screens/home_screen.dart';
import 'package:goodlife_party/widgets/primary_button.dart';

class ActionButtons extends StatelessWidget {
  final UserRole? selectedRole;
  final bool isIOS;

  const ActionButtons({
    required this.selectedRole,
    required this.isIOS,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedRole == null) return const SizedBox();

    final loginButton = PrimaryButton(
      text: "Login",
      onPressed: () {
        // TODO: Navigate to login
      },
      isIOS: isIOS,
    );

    final signupButton = SecondaryButton(
      text: "Sign Up",
      onPressed: () {
        // TODO: Navigate to signup
      },
      isIOS: isIOS,
    );

    return Column(
      children: [
        loginButton,
        const SizedBox(height: 12),

        /// Only for USER
        if (selectedRole == UserRole.user) signupButton,
      ],
    );
  }
}