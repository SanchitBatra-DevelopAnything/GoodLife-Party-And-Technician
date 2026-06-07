import 'package:flutter/material.dart';

import '../models/executive_delivery_order.dart';

class ExecutiveOrderStatusHelper {
  static String getStatusText(
    ExecutiveDeliveryOrder order,
  ) {
    if (order.status == 'PENDING') {
      return 'Payment Rejected';
    }

    if (order.status ==
        'PAYMENT_VERIFICATION') {
      return 'Payment Verification In Progress';
    }

    if (order.status ==
            'PAYMENT_VERIFIED' &&
        order.dispatchedOn == null) {
      return 'Payment Verified';
    }

    if ((order.status ==
                'PAYMENT_VERIFIED' ||
            order.status ==
                'DISPATCHED') &&
        order.dispatchedOn != null) {
      return 'Order Dispatched';
    }

    return order.status;
  }

  static Color getStatusColor(
    ExecutiveDeliveryOrder order,
  ) {
    if (order.status == 'PENDING') {
      return Colors.red;
    }

    if (order.status ==
        'PAYMENT_VERIFICATION') {
      return Colors.orange;
    }

    if (order.dispatchedOn != null) {
      return Colors.blue;
    }

    return Colors.green;
  }

  static IconData getStatusIcon(
    ExecutiveDeliveryOrder order,
  ) {
    if (order.status == 'PENDING') {
      return Icons.cancel;
    }

    if (order.status ==
        'PAYMENT_VERIFICATION') {
      return Icons.hourglass_bottom;
    }

    if (order.dispatchedOn != null) {
      return Icons.local_shipping;
    }

    return Icons.check_circle;
  }
}