import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  static const languages = {
    'en': 'English',
    'hi': 'Hindi',
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final isIOS = Platform.isIOS;

    if (isIOS) {
      return CupertinoButton(
        child: Text(languages[provider.locale.languageCode]!),
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (_) => CupertinoActionSheet(
              title: const Text("Select Language"),
              actions: languages.entries.map((entry) {
                return CupertinoActionSheetAction(
                  onPressed: () {
                    provider.setLocale(entry.key);
                    Navigator.pop(context);
                  },
                  child: Text(entry.value),
                );
              }).toList(),
            ),
          );
        },
      );
    }

    return DropdownButton<String>(
      value: provider.locale.languageCode,
      isExpanded: true,
      items: languages.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          provider.setLocale(value);
        }
      },
    );
  }
}