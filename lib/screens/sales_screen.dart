import 'package:flutter/material.dart';
import 'package:goodlife_party/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../widgets/bottom_nav_bar.dart';

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

    final salesPerson = authProvider.salesPerson;
    final salesContact = authProvider.salesContact.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Support'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.support_agent,
                      size: 72,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      salesPerson,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      salesContact,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _call(salesContact),
                        icon: const Icon(Icons.call),
                        label: const Text(
                          'Call Sales Person',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _whatsapp(salesContact),
                        icon: const Icon(Icons.chat),
                        label: const Text(
                          'WhatsApp Sales Person',
                        ),
                      ),
                    ),
                  ],
                ),
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