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
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.isIOS,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;

    if (isIOS) {
      return GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey4,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title, // ✅ already supports localized string
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.check_mark,
                  size: 20,
                  color: CupertinoColors.activeBlue,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RadioListTile<UserRole>(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        title, // ✅ already supports localized string
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}