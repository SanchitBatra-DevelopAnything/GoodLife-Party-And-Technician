import 'package:flutter/material.dart';
import 'package:goodlife_party/providers/cart_provider.dart';
import 'package:goodlife_party/routes/app_routes.dart';
import 'package:provider/provider.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final cartCount =
        context.watch<CartProvider>().itemCount;

    return BottomNavigationBar(
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
              AppRoutes.home,
              (route) => false,
            );
            break;

          case 1:
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.categories,
              (route) => false,
            );
            break;

          case 2:
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.cart,
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

      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: '',
        ),

        BottomNavigationBarItem(
          label: '',

          icon: Stack(
            clipBehavior: Clip.none,

            children: [
              const Icon(Icons.shopping_cart),

              if (cartCount > 0)
                Positioned(
                  right: -6,
                  top: -6,

                  child: Container(
                    padding:
                        const EdgeInsets.all(5),

                    decoration: BoxDecoration(
                      color: Colors.red,

                      borderRadius:
                          BorderRadius.circular(
                        100,
                      ),
                    ),

                    constraints:
                        const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),

                    child: Text(
                      cartCount > 99
                          ? '99+'
                          : cartCount.toString(),

                      textAlign:
                          TextAlign.center,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: '',
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '',
        ),
      ],
    );
  }
}