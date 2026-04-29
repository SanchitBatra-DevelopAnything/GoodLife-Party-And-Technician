import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/widgets/action_button.dart';
import 'package:goodlife_party/widgets/app_logo.dart';
import 'package:goodlife_party/widgets/language_dropdown.dart';
import 'package:goodlife_party/widgets/role_selector.dart';

enum UserRole { technician, user }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;

    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            /// 🔹 LOGO
            AppLogo(),

            const SizedBox(height: 40),

            /// 🔹 ROLE SELECTION
            RoleSelector(
              selectedRole: selectedRole,
              onChanged: (role) {
                setState(() {
                  selectedRole = role;
                });
              },
            ),

            const SizedBox(height: 20),

            LanguageDropdown(),

            const SizedBox(height: 20),

            const Spacer(),

            /// 🔹 ACTION BUTTONS
            ActionButtons(selectedRole: selectedRole, isIOS: isIOS),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );

    return isIOS
        ? CupertinoPageScaffold(child: content)
        : Scaffold(body: content);
  }
}
