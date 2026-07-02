import 'package:flutter/material.dart';

import '../models/executive_delivery_order.dart';
import '../widgets/executive_order_documents_section.dart';
import '../widgets/executive_order_items_section.dart';
import '../widgets/executive_order_status_card.dart';

class ExecutiveOrderDetailsScreen extends StatelessWidget {
  final ExecutiveDeliveryOrder order;

  const ExecutiveOrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ExecutiveOrderStatusCard(
              order: order,
            ),

            if (order.isExpressDelivery) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade50, Colors.orange.shade100],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.electric_bolt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Express Delivery Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'This order is flagged for high priority fast dispatch.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            buildPriceBreakdownCard(),

            const SizedBox(height: 16),

            ExecutiveOrderItemsSection(
              items: order.items,
            ),

            const SizedBox(height: 16),

            ExecutiveOrderDocumentsSection(
              documents: order.documents,
            ),

            const SizedBox(height: 16),

            buildOrderInformationCard(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget buildPriceBreakdownCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            buildAmountRow(
              'Item Total',
              order.itemTotal,
            ),

            buildAmountRow(
              'Delivery Charges',
              order.freightCharges,
            ),

            if (order.gstAmount > 0)
              buildAmountRow(
                'GST',
                order.gstAmount,
              ),

            const Divider(
              height: 24,
            ),

            buildAmountRow(
              'Grand Total',
              order.totalPrice,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderInformationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            buildInfoRow(
              'Order ID',
              order.orderId,
            ),

            buildInfoRow(
              'Order Date',
              order.orderDate,
            ),

            buildInfoRow(
              'Order Time',
              order.orderTime,
            ),

            buildInfoRow(
              'Ordered By',
              order.orderedBy,
            ),

            buildInfoRow(
              'Contact',
              order.contact,
            ),

            buildInfoRow(
              'Area',
              order.area,
            ),

            if (order.dispatchedOn !=
                null)
              buildInfoRow(
                'Dispatched On',
                order.dispatchedOn!,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
            vertical: 6,
          ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAmountRow(
    String title,
    double amount, {
    bool isBold = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
            vertical: 6,
          ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight:
                    isBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                fontSize:
                    isBold ? 16 : 14,
              ),
            ),
          ),

          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight:
                  isBold
                      ? FontWeight.bold
                      : FontWeight.normal,
              fontSize:
                  isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}