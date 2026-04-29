import 'package:flutter/material.dart';
import 'package:goodlife_party/l10n/app_localizations.dart';

class AppLogo extends StatelessWidget {
  const AppLogo();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        /// Replace with your asset
        Image.asset(
          'assets/logo.jpeg',
          height: 100,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}