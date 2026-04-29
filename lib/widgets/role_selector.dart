import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goodlife_party/screens/home_screen.dart';
import 'package:goodlife_party/widgets/role_tile.dart';

class RoleSelector extends StatelessWidget {
  final UserRole? selectedRole;
  final Function(UserRole) onChanged;

  const RoleSelector({
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;

    return Column(
      children: [
        RoleTile(
          title: "I am a technician",
          value: UserRole.technician,
          groupValue: selectedRole,
          onChanged: onChanged,
          isIOS: isIOS,
        ),
        const SizedBox(height: 12),
        RoleTile(
          title: "I am a user",
          value: UserRole.user,
          groupValue: selectedRole,
          onChanged: onChanged,
          isIOS: isIOS,
        ),
      ],
    );
  }
}