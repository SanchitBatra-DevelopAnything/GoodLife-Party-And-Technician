import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../providers/cart_provider.dart';
import 'quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice =
        cartItem.price * cartItem.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(16),

            child: cartItem.imageUrl.isEmpty
                ? Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  )
                : CachedNetworkImage(
                    imageUrl: cartItem.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  cartItem.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '₹${cartItem.price.toStringAsFixed(0)} each',

                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                if (cartItem.customizedMessage
                    .isNotEmpty) ...[
                  const SizedBox(height: 10),

                  Container(
                    padding:
                        const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      color:
                          Colors.orange.shade50,

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),

                    child: Text(
                      cartItem.customizedMessage,

                      style: TextStyle(
                        color:
                            Colors.orange.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    QuantitySelector(
                      quantity:
                          cartItem.quantity.toInt(),

                      onAdd: onAdd,

                      onRemove: onRemove,
                    ),

                    Text(
                      '₹${totalPrice.toStringAsFixed(0)}',

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}