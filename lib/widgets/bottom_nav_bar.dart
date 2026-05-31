import 'package:flutter/material.dart';
import 'package:goodlife_party/providers/cart_provider.dart';
import 'package:goodlife_party/routes/app_routes.dart';
import 'package:provider/provider.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCartBar && cartCount > 0)
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                8,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.cart,
                    );
                  },
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
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
                            cartCount > 99
                                ? '99+'
                                : cartCount.toString(),
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
                        const Text(
                          'View Cart',
                          style: TextStyle(
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
          ),

        BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == currentIndex) {
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
                  AppRoutes.categories,
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale_rounded),
              label: 'Sales',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Spare Parts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_rounded),
              label: 'Service',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'My Profile',
            ),
          ],
        ),
      ],
    );
  }
}