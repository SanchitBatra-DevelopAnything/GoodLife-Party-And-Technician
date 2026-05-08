import 'package:flutter/material.dart';
import 'package:goodlife_party/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';

import '../../widgets/cart/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (
        context,
        cartProvider,
        child,
      ) {
        final cartItems =
            cartProvider.items.values.toList();

        return Scaffold(
          backgroundColor:
              Colors.grey.shade100,

          appBar: AppBar(
            title: const Text('My Cart'),
            centerTitle: true,
          ),

          bottomNavigationBar:
              AppBottomNavBar(
            currentIndex: 2,
            
          ),

          body: cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        itemCount:
                            cartItems.length,
                        itemBuilder:
                            (context, index) {
                          final cartItem =
                              cartItems[index];

                          return CartItemCard(
                            cartItem: cartItem,

                            onAdd: () {
                              cartProvider
                                  .addItem(
                                cartItem.id,
                                cartItem.price,
                                cartItem.quantity +
                                    1,
                                cartItem.title,
                                cartItem.imageUrl,
                                '',
                                cartItem
                                    .customizedMessage,
                              );
                            },

                            onRemove: () {
                              if (cartItem
                                      .quantity <=
                                  1) {
                                cartProvider
                                    .removeItem(
                                  cartItem.id,
                                );
                              } else {
                                cartProvider
                                    .addItem(
                                  cartItem.id,
                                  cartItem.price,
                                  cartItem.quantity -
                                      1,
                                  cartItem.title,
                                  cartItem.imageUrl,
                                  '',
                                  cartItem
                                      .customizedMessage,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      decoration:
                          const BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.vertical(
                          top:
                              Radius.circular(28),
                        ),
                      ),

                      child: Column(
                        children: [
                          buildPriceRow(
                            'Subtotal',
                            cartProvider
                                .subtotal,
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          buildPriceRow(
                            'GST (18%)',
                            cartProvider.gst,
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          buildPriceRow(
                            'Freight Charges',
                            cartProvider
                                .freightCharges,
                          ),

                          const Padding(
                            padding:
                                EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            child: Divider(),
                          ),

                          buildPriceRow(
                            'Grand Total',
                            cartProvider
                                .grandTotal,
                            isBold: true,
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          SizedBox(
                            width:
                                double.infinity,
                            height: 60,
                            child:
                                ElevatedButton(
                              onPressed: () {},

                              style:
                                  ElevatedButton.styleFrom(
                                elevation: 0,

                                backgroundColor:
                                    Theme.of(
                                  context,
                                ).primaryColor,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      const Text(
                                        'Total Amount',

                                        style:
                                            TextStyle(
                                          color: Colors
                                              .white70,
                                          fontSize:
                                              13,
                                        ),
                                      ),

                                      Text(
                                        '₹${cartProvider.grandTotal.toStringAsFixed(0)}',

                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .white,

                                          fontSize:
                                              20,

                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: const [
                                      Text(
                                        'Place Order',

                                        style:
                                            TextStyle(
                                          fontSize:
                                              17,

                                          fontWeight:
                                              FontWeight
                                                  .w700,

                                          color: Colors
                                              .white,
                                        ),
                                      ),

                                      SizedBox(
                                        width: 8,
                                      ),

                                      Icon(
                                        Icons
                                            .arrow_forward_rounded,

                                        color: Colors
                                            .white,
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

  Widget buildPriceRow(
    String title,
    double value, {
    bool isBold = false,
  }) {
    final style = TextStyle(
      fontSize: isBold ? 18 : 15,

      fontWeight: isBold
          ? FontWeight.bold
          : FontWeight.w500,
    );

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Text(title, style: style),

        Text(
          '₹${value.toStringAsFixed(0)}',

          style: style,
        ),
      ],
    );
  }
}