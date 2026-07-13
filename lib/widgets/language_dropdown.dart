import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  static const languages = {
    'en': 'English',
    'hi': 'हिन्दी (Hindi)',
    'bn': 'বাংলা (Bengali)',
    'mr': 'मराठी (Marathi)',
    'te': 'తెలుగు (Telugu)',
    'ta': 'தமிழ் (Tamil)',
    'gu': 'ગુજરાતી (Gujarati)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'or': 'ଓଡ଼ିଆ (Odia)',
    'ml': 'മലയാളം (Malayalam)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final isIOS = Platform.isIOS;
    final l10n = AppLocalizations.of(context);

    if (isIOS) {
      return CupertinoButton(
        child: Text(languages[provider.locale.languageCode] ?? 'English'),
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (_) => CupertinoActionSheet(
              title: Text(l10n?.selectLanguage ?? "Select Language"),
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