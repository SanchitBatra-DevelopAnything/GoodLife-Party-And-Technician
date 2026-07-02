import 'package:flutter/material.dart';

import '../models/executive_delivery_order.dart';

class ExecutiveOrderCard extends StatelessWidget {
  final ExecutiveDeliveryOrder order;
  final VoidCallback onTap;

  const ExecutiveOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  String getStatusText() {
    if (order.status == 'PENDING') {
      return 'Payment Rejected';
    }

    if (order.status == 'PAYMENT_VERIFICATION') {
      return 'Payment Verification';
    }

    if (order.status == 'PAYMENT_VERIFIED' &&
        order.dispatchedOn == null) {
      return 'Payment Verified';
    }

    if ((order.status == 'PAYMENT_VERIFIED' ||
            order.status == 'DISPATCHED') &&
        order.dispatchedOn != null) {
      return 'Order Dispatched';
    }

    return order.status;
  }

  Color getStatusColor() {
    if (order.status == 'PENDING') {
      return Colors.red;
    }

    if (order.status == 'PAYMENT_VERIFICATION') {
      return Colors.orange;
    }

    if (order.dispatchedOn != null) {
      return Colors.blue;
    }

    return Colors.green;
  }

  IconData getStatusIcon() {
    if (order.status == 'PENDING') {
      return Icons.cancel_rounded;
    }

    if (order.status == 'PAYMENT_VERIFICATION') {
      return Icons.hourglass_bottom_rounded;
    }

    if (order.dispatchedOn != null) {
      return Icons.local_shipping_rounded;
    }

    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor();

    final shortOrderId =
        order.orderId.length > 8
            ? order.orderId.substring(0, 8)
            : order.orderId;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surface,
              borderRadius:
                  BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.05,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  /// STATUS
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color: statusColor
                          .withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          getStatusIcon(),
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          getStatusText(),
                          style: TextStyle(
                            color:
                                statusColor,
                            fontWeight:
                                FontWeight
                                    .w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  /// AMOUNT
                  Text(
                    '₹${order.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.w800,
                      height: 1,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    '${order.items.length} Items',
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// CUSTOMER
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .all(8),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey.shade100,
                          shape:
                              BoxShape.circle,
                        ),
                        child: Icon(
                          Icons
                              .person_outline_rounded,
                          size: 18,
                          color: Colors
                              .grey.shade700,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          order.orderedBy,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  /// DATE
                  Row(
                    children: [
                      Icon(
                        Icons
                            .schedule_rounded,
                        size: 18,
                        color: Colors
                            .grey.shade600,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          '${order.orderDate} • ${order.orderTime}',
                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  /// ORDER ID BADGE
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey.shade100,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          '#$shortOrderId',
                          style: TextStyle(
                            color: Colors
                                .grey.shade700,
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (order.isExpressDelivery) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                            border: Border.all(
                              color: Colors.orange.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.electric_bolt_rounded,
                                size: 12,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Express',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (order.dispatchedOn !=
                      null) ...[
                    const SizedBox(
                      height: 14,
                    ),
                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .all(12),
                      decoration:
                          BoxDecoration(
                        color: Colors.blue
                            .withOpacity(
                          0.08,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .local_shipping_rounded,
                            size: 18,
                            color:
                                Colors.blue,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text(
                              'Dispatched on ${order.dispatchedOn}',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 16,
                  ),

                  const Divider(),

                  const SizedBox(
                    height: 8,
                  ),

                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: const [
                        Text(
                          'View Details',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}