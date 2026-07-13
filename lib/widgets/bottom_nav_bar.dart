import 'package:flutter/material.dart';
import 'package:goodlife_party/providers/cart_provider.dart';
import 'package:goodlife_party/providers/outstanding_balance_provider.dart';
import 'package:goodlife_party/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool showCartBar;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    this.showCartBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartCount = cartProvider.itemCount;
    final l10n = AppLocalizations.of(context)!;

    // Real-time outstanding balance
    final balanceProvider = context.watch<OutstandingBalanceProvider>();
    final balance = balanceProvider.outstandingBalance;
    final showBalanceBanner = balanceProvider.payLater == true && balance > 0;
    final formattedBalance = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(balance);

    // Allows screens to pass -1, 100, etc. → no tab will appear selected.
    final bool hasSelectedTab = currentIndex >= 0 && currentIndex <= 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Outstanding Balance Banner (always visible when payLater=true) ──
        if (showBalanceBanner)
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade700,
                      Colors.red.shade500,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade300.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Outstanding Balance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formattedBalance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.yellowAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Cart Bar ─────────────────────────────────────────────────────
        if (showCartBar && cartCount > 0)
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.cart);
                  },
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            cartCount > 99 ? '99+' : cartCount.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$cartCount item${cartCount > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          l10n.viewCart,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        else if (showBalanceBanner)
          const SizedBox(height: 8),

        // ── Bottom Navigation Bar ─────────────────────────────────────────
        Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: hasSelectedTab ? currentIndex : 0,
            type: BottomNavigationBarType.fixed,

            selectedItemColor: hasSelectedTab
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,

            unselectedItemColor: Colors.grey,

            onTap: (index) {
              if (index == currentIndex) {
                if (index == 4 &&
                    ModalRoute.of(context)?.settings.name !=
                        AppRoutes.profile) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.profile,
                      (route) => false,
                    );
                  }
                }
                return;
              }

              switch (index) {
                case 0:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.inventory,
                    (route) => false,
                  );
                  break;

                case 1:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.sales,
                    (route) => false,
                  );
                  break;

                case 2:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.sparePartOptions,
                    (route) => false,
                  );
                  break;

                case 3:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.serviceRequestForm,
                    (route) => false,
                  );
                  break;

                case 4:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.profile,
                    (route) => false,
                  );
                  break;
              }
            },

            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: l10n.navHome,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.point_of_sale_rounded),
                label: l10n.navSales,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.inventory_2_rounded),
                label: l10n.navSpareParts,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.build_rounded),
                label: l10n.navService,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: l10n.navMyProfile,
              ),
            ],
          ),
        ),
      ],
    );
  }
}