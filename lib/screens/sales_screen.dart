import 'package:flutter/material.dart';
import 'package:goodlife_party/providers/auth_provider.dart';
import 'package:goodlife_party/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  Future<void> _call(String number) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: number,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsapp(String number) async {
    final Uri uri = Uri.parse(
      'https://wa.me/$number',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    final salesPerson = authProvider.salesPerson;
    final salesContact = authProvider.salesContact.toString();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.salesSupport,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.contactSalesExecutive,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor:
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.12),
                    child: Icon(
                      Icons.person,
                      size: 42,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    salesPerson,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    salesContact,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _call(salesContact),
                      icon: const Icon(Icons.call),
                      label: Text(
                        l10n.callSalesPerson,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _whatsapp(salesContact),
                      icon: const Icon(Icons.chat),
                      label: Text(
                        l10n.whatsAppSalesPerson,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}