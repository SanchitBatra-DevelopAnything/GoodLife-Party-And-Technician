import 'package:flutter/material.dart';

import '../models/executive_delivery_order.dart';
import '../widgets/executive_order_documents_section.dart';
import '../widgets/executive_order_items_section.dart';
import '../widgets/executive_order_status_card.dart';
import '../l10n/app_localizations.dart';

class ExecutiveOrderDetailsScreen extends StatelessWidget {
  final ExecutiveDeliveryOrder order;

  const ExecutiveOrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.orderDetailsTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ExecutiveOrderStatusCard(
              order: order,
            ),

            const SizedBox(height: 16),

            buildPriceBreakdownCard(l10n),

            const SizedBox(height: 16),

            ExecutiveOrderItemsSection(
              items: order.items,
            ),

            const SizedBox(height: 16),

            ExecutiveOrderDocumentsSection(
              documents: order.documents,
            ),

            const SizedBox(height: 16),

            buildOrderInformationCard(l10n),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget buildPriceBreakdownCard(AppLocalizations l10n) {
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
            Text(
              l10n.priceBreakdown,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            buildAmountRow(
              l10n.itemTotal,
              order.itemTotal,
            ),

            buildAmountRow(
              l10n.freightCharges,
              order.freightCharges,
            ),


            const Divider(
              height: 24,
            ),

            buildAmountRow(
              l10n.grandTotal,
              order.totalPrice,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderInformationCard(AppLocalizations l10n) {
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
            Text(
              l10n.orderInformation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            buildInfoRow(
              l10n.orderId,
              order.orderId,
            ),

            buildInfoRow(
              l10n.orderDateStr,
              order.orderDate,
            ),

            buildInfoRow(
              l10n.orderTimeStr,
              order.orderTime,
            ),

            buildInfoRow(
              l10n.orderedBy,
              order.orderedBy,
            ),

            buildInfoRow(
              l10n.contact,
              order.contact,
            ),

            buildInfoRow(
              l10n.areaText,
              order.area,
            ),

            if (order.dispatchedOn !=
                null)
              buildInfoRow(
                l10n.dispatchedOnStr,
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