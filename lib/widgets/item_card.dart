import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/models/item_model.dart';
import 'package:goodlife_party/providers/cart_provider.dart';
import 'package:goodlife_party/screens/item_details_screen.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;

  const ItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailsScreen(
                      item: item,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: item.id,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.imgUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
  builder: (context) {
    final cartProvider =
        context.watch<CartProvider>();

    final isInCart =
        cartProvider.checkInCart(item.id);

    final quantity =
        cartProvider.getQuantity(item.id);

    if (!isInCart) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            String customizedMessage = '';

            if (item.isCustomizable) {
              final wantsCustomization =
                  await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Customization',
                    ),
                    content: const Text(
                      'Do you want to add customization?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            false,
                          );
                        },
                        child: const Text('No'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            true,
                          );
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );

              if (wantsCustomization == true) {
                final controller =
                    TextEditingController();

                final message =
                    await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Add Message',
                      ),
                      content: TextField(
                        controller: controller,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(
                          hintText:
                              'Enter customization',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          child: const Text(
                            'Cancel',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              controller.text,
                            );
                          },
                          child: const Text(
                            'Add',
                          ),
                        ),
                      ],
                    );
                  },
                );

                customizedMessage =
                    message ?? '';
              }
            }

            cartProvider.addItem(
              item.id,
              item.price,
              1,
              item.itemName,
              item.imgUrl,
              '',
              customizedMessage,
            );
          },
          child: const Text(
            'Add To Cart',
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context)
              .primaryColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: IconButton(
              onPressed: () {
                if (quantity <= 1) {
                  cartProvider.removeItem(
                    item.id,
                  );
                } else {
                  cartProvider.addItem(
                    item.id,
                    item.price,
                    quantity - 1,
                    item.itemName,
                    item.imgUrl,
                    '',
                    cartProvider
                            .items[item.id]
                            ?.customizedMessage ??
                        '',
                  );
                }
              },
              icon: const Icon(Icons.remove),
            ),
          ),
          Text(
            quantity.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                cartProvider.addItem(
                  item.id,
                  item.price,
                  quantity + 1,
                  item.itemName,
                  item.imgUrl,
                  '',
                  cartProvider
                          .items[item.id]
                          ?.customizedMessage ??
                      '',
                );
              },
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  },
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}