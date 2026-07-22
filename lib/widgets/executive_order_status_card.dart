import 'package:flutter/material.dart';

import '../models/executive_delivery_order.dart';
import '../utils/executive_order_status_helper.dart';
import '../l10n/app_localizations.dart';

class ExecutiveOrderStatusCard
    extends StatelessWidget {
  final ExecutiveDeliveryOrder order;

  const ExecutiveOrderStatusCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color =
        ExecutiveOrderStatusHelper
            .getStatusColor(order);

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(
          0.12,
        ),
        borderRadius:
            BorderRadius.circular(
              18,
            ),
      ),
      child: Row(
        children: [
          Icon(
            ExecutiveOrderStatusHelper
                .getStatusIcon(order),
            color: color,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ExecutiveOrderStatusHelper
                  .getStatusText(order, l10n),
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}