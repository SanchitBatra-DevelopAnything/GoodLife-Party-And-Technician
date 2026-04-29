import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goodlife_party/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        RoleTile(
          title: l10n.technician,
          value: UserRole.technician,
          groupValue: selectedRole,
          onChanged: onChanged,
          isIOS: isIOS,
        ),
        const SizedBox(height: 12),
        RoleTile(
          title: l10n.user,
          value: UserRole.user,
          groupValue: selectedRole,
          onChanged: onChanged,
          isIOS: isIOS,
        ),
      ],
    );
  }
}