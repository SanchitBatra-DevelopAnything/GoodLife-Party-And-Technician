import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/screens/home_screen.dart';

class RoleTile extends StatelessWidget {
  final String title;
  final UserRole value;
  final UserRole? groupValue;
  final Function(UserRole) onChanged;
  final bool isIOS;
  

  const RoleTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.isIOS,
  });

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: groupValue == value
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              if (groupValue == value)
                const Icon(CupertinoIcons.check_mark),
            ],
          ),
        ),
      );
    }

    return RadioListTile<UserRole>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}