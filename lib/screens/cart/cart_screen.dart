import 'package:flutter/material.dart';
import 'package:goodlife_party/providers/auth_provider.dart';
import 'package:goodlife_party/widgets/bottom_nav_bar.dart';
import 'package:goodlife_party/widgets/payment_option_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cart/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<CartProvider>().setFreightPercentage(
            authProvider.freightPercentage,
          );
        });

        final cartItems = cartProvider.items.values.toList();

        return Scaffold(
          backgroundColor: Colors.grey.shade100,

          appBar: AppBar(title: Text(AppLocalizations.of(context)!.myCart), centerTitle: true),

          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 2,
            showCartBar: false,
          ),

          body: cartItems.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.cartEmpty))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartItems[index];

                          return CartItemCard(
                            cartItem: cartItem,

                            onAdd: () {
                              cartProvider.addItem(
                                cartItem.id,
                                cartItem.price,
                                cartItem.quantity + 1,
                                cartItem.title,
                                cartItem.imageUrl,
                                '',
                                cartItem.customizedMessage,
                              );
                            },

                            onRemove: () {
                              if (cartItem.quantity <= 1) {
                                cartProvider.removeItem(cartItem.id);
                              } else {
                                cartProvider.addItem(
                                  cartItem.id,
                                  cartItem.price,
                                  cartItem.quantity - 1,
                                  cartItem.title,
                                  cartItem.imageUrl,
                                  '',
                                  cartItem.customizedMessage,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: const BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),

                      child: Column(
                        children: [
                          buildPriceRow(context, AppLocalizations.of(context)!.subtotal, cartProvider.subtotal),


                          buildPriceRow(
                            context,
                            AppLocalizations.of(context)!.freightCharges,
                            cartProvider.freightCharges,
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(),
                          ),

                          buildPriceRow(
                            context,
                            AppLocalizations.of(context)!.grandTotal,
                            cartProvider.grandTotal,
                            isBold: true,
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    return PaymentOptionBottomSheet(
                                      grandTotal: cartProvider.grandTotal,
                                    );
                                  },
                                );
                              },

                              style: ElevatedButton.styleFrom(
                                elevation: 0,

                                backgroundColor: Theme.of(context).primaryColor,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.totalAmount,

                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),

                                      Text(
                                        '₹${cartProvider.grandTotal.toStringAsFixed(0)}',

                                        style: const TextStyle(
                                          color: Colors.white,

                                          fontSize: 20,

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.placeOrder,

                                        style: const TextStyle(
                                          fontSize: 17,

                                          fontWeight: FontWeight.w700,

                                          color: Colors.white,
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      const Icon(
                                        Icons.arrow_forward_rounded,

                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget buildPriceRow(BuildContext context, String title, double value, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: isBold ? 18 : 15,

      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(title, style: style),

        Text('\u20b9${value.toStringAsFixed(0)}', style: style),
      ],
    );
  }
}
