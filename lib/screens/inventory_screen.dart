import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodlife_party/providers/categories_provider.dart';
import 'package:goodlife_party/providers/whats_new_provider.dart';
import 'package:goodlife_party/widgets/bottom_nav_bar.dart';
import 'package:goodlife_party/widgets/category_shimmer.dart';
import 'package:goodlife_party/widgets/inventory_item.dart';
import 'package:goodlife_party/widgets/whats_new_popup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'package:upgrader/upgrader.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();

    loadUser();

    Future.microtask(() async {
      await Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).fetchCategories();

      final whatsNewProvider = Provider.of<WhatsNewProvider>(
        context,
        listen: false,
      );

      await whatsNewProvider.fetchWhatsNew();

      if (!mounted) return;

      if (whatsNewProvider.items.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => WhatsNewDialog(
            items: whatsNewProvider.items,
          ),
        );
      }
    });
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('logged_in_user');

    if (userString != null) {
      final userMap = jsonDecode(userString);

      setState(() {
        userName = userMap['distributorName'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.exitApp),
            content: Text(l10n.closeAppConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.no),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.yes),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: UpgradeAlert(
        upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(hours: 1),
          dialogStyle: UpgradeDialogStyle.material,
        ),
        child: Scaffold(
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
                        Icons.precision_manufacturing_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.machineInventory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.byGoodlife,
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
                        Icons.inventory_2_outlined,
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

        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: TextField(
                  onChanged: provider.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchMachines,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: provider.isLoading
                    ? const CategoryShimmer()
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: provider.categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.78,
                            ),
                        itemBuilder: (context, index) {
                          final machine =
                              provider.categories[index];

                          return InventoryItem(
                            machine: machine,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 0,
        ),
      ),
    );
  }
}