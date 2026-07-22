import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodlife_party/providers/auth_provider.dart';
import 'package:goodlife_party/providers/outstanding_balance_provider.dart';
import 'package:goodlife_party/routes/app_routes.dart';
import 'package:goodlife_party/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    // If not logged in, auto-redirect to home route
    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final distributor = authProvider.distributorDetails;
    final area = authProvider.areaDetails;

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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
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
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.myProfile,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          distributor?.distributorName ?? l10n.partyProfile,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: l10n.logout,
                    onPressed: () => _showLogoutConfirmation(context, authProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Profile Header card
              _buildProfileHeaderCard(distributor, area),
              const SizedBox(height: 16),

              // 2. Options List
              _buildOptionsCard(context, authProvider),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 4,
      ),
    );
  }

  Widget _buildProfileHeaderCard(distributor, area) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Text(
                (distributor?.distributorName ?? 'U').substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    distributor?.distributorName ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_iphone_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        distributor?.contact ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        distributor?.area ?? area?.areaName ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context, AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded, color: Colors.green),
            ),
            title: Text(
              l10n.mySparePartOrders,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.myOrdersSpareParts);
            },
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.build_rounded, color: Colors.blue),
            ),
            title: Text(
              l10n.myServiceRequests,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.myServiceRequests);
            },
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.translate_rounded, color: Colors.purple),
            ),
            title: Text(
              l10n.selectLanguage,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => _showLanguageSelector(context),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.orange),
            ),
            title: Text(
              l10n.logout,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => _showLogoutConfirmation(context, authProvider),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            ),
            title: Text(
              l10n.deleteMyAccount,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => _showDeleteAccountConfirmation(context, authProvider),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale.languageCode;
    final l10n = AppLocalizations.of(context)!;

    const languages = {
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

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (ctx, index) {
                final entry = languages.entries.elementAt(index);
                final isSelected = entry.key == currentLocale;
                return ListTile(
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                  onTap: () {
                    localeProvider.setLocale(entry.key);
                    Navigator.pop(dialogCtx);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context, AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.deleteAccountTitle),
          content: Text(l10n.deleteAccountConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogCtx); // close dialog
                // Stop the outstanding balance listener before logout
                if (context.mounted) {
                  Provider.of<OutstandingBalanceProvider>(context, listen: false)
                      .stopListening();
                }
                // Assuming logout handles local clearing for now, until API is ready
                await authProvider.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
              child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.logoutConfirmTitle),
          content: Text(l10n.areYouSure),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogCtx); // close dialog
                // Stop the outstanding balance listener before logout
                if (context.mounted) {
                  Provider.of<OutstandingBalanceProvider>(context, listen: false)
                      .stopListening();
                }
                await authProvider.logout();
                if (!context.mounted) return;
                // Redirect to Home with cleared history
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
              child: Text(l10n.yes, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
