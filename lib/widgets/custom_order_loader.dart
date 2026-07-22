import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class InquiryOrderLoader extends StatelessWidget {
  final String message;

  const InquiryOrderLoader({
    super.key,
    required this.message,
  });

  String _getLocalizedMessage(BuildContext context, String msg) {
    final l10n = AppLocalizations.of(context)!;
    if (msg.startsWith('Uploading')) {
      final regex = RegExp(r'(\d+)\s*of\s*(\d+)');
      final match = regex.firstMatch(msg);
      if (match != null) {
        return '${l10n.uploading.replaceAll("...", "")} ${match.group(1)}/${match.group(2)}';
      }
      return l10n.uploading;
    } else if (msg.contains('Creating') || msg.contains('Preparing') || msg.contains('Saving') || msg.contains('Validating')) {
      return l10n.submittingRequest;
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.submittingRequest,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _getLocalizedMessage(context, message),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}