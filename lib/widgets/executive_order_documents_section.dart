import 'package:flutter/material.dart';

import '../services/document_download_service.dart';
import '../l10n/app_localizations.dart';

class ExecutiveOrderDocumentsSection
    extends StatelessWidget {
  final List<String> documents;

  const ExecutiveOrderDocumentsSection({
    super.key,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (documents.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              l10n.documentsText,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            ...documents.asMap().entries.map(
              (entry) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .insert_drive_file,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          l10n.documentNumber(entry.key + 1),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await DocumentDownloadService()
                              .openDocument(
                            entry.value,
                          );
                        },
                        child: Text(
                          l10n.openText,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}