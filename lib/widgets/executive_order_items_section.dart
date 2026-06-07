import 'package:flutter/material.dart';

import '../models/executive_delivery_order.dart';

class ExecutiveOrderItemsSection
    extends StatelessWidget {
  final List<ExecutiveDeliveryItem>
      items;

  const ExecutiveOrderItemsSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${items.length})',
              style:
                  const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 16),

            ...items.map(
              (item) {
                return Container(
                  margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                  padding:
                      const EdgeInsets.all(
                        12,
                      ),
                  decoration:
                      BoxDecoration(
                        border:
                            Border.all(
                              color: Colors
                                  .grey
                                  .shade300,
                            ),
                        borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                      ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        item.name,
                        style:
                            const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Qty : ${item.quantity}',
                      ),
                      Text(
                        'Price : ₹${item.price}',
                      ),
                      Text(
                        'Total : ₹${item.totalPrice}',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}