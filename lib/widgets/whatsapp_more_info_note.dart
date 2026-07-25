import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

class WhatsAppMoreInfoNote extends StatelessWidget {
  const WhatsAppMoreInfoNote({super.key});

  static const String _whatsAppPhone = '919870361004';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () async {
        final uri = Uri.parse(
          'https://api.whatsapp.com/send?phone=$_whatsAppPhone',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F5EC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF25D366).withOpacity(0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(text: l10n.whatsAppMoreInfoNote),
                    TextSpan(
                      text: l10n.whatsAppSupportPhone,
                      style: const TextStyle(
                        color: Color(0xFF25D366),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
