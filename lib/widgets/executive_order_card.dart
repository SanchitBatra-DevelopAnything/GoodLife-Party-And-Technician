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

  Color getStatusColor() {
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

  IconData getStatusIcon() {
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

  @override
  Widget build(BuildContext context) {
    final statusColor =
        getStatusColor();

    return Padding(
      padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).cardColor,
              borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(
                        0.05,
                      ),
                  blurRadius: 10,
                  offset: const Offset(
                    0,
                    4,
                  ),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(
                    18,
                  ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.orderId.length > 8 ? order.orderId.substring(0, 8) : order.orderId}',
                          style:
                              const TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal:
                                  12,
                              vertical:
                                  6,
                            ),
                        decoration:
                            BoxDecoration(
                              color: statusColor
                                  .withOpacity(
                                    0.12,
                                  ),
                              borderRadius:
                                  BorderRadius.circular(
                                    20,
                                  ),
                            ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            Icon(
                              getStatusIcon(),
                              size: 14,
                              color:
                                  statusColor,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              getStatusText(),
                              style:
                                  TextStyle(
                                    color:
                                        statusColor,
                                    fontSize:
                                        12,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Row(
                    children: [
                      Icon(
                        Icons
                            .calendar_today_outlined,
                        size: 16,
                        color: Colors
                            .grey
                            .shade600,
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
                    height: 10,
                  ),

                  Row(
                    children: [
                      Icon(
                        Icons
                            .person_outline,
                        size: 16,
                        color: Colors
                            .grey
                            .shade600,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          order.orderedBy,
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

                  Container(
                    padding:
                        const EdgeInsets.all(
                          14,
                        ),
                    decoration:
                        BoxDecoration(
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .surface
                              .withOpacity(
                                0.5,
                              ),
                          borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                        ),
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              _InfoTile(
                                title:
                                    'Items',
                                value:
                                    '${order.items.length}',
                                icon:
                                    Icons.inventory_2_outlined,
                              ),
                        ),

                        Container(
                          height: 40,
                          width: 1,
                          color:
                              Colors.grey.shade300,
                        ),

                        Expanded(
                          child:
                              _InfoTile(
                                title:
                                    'Amount',
                                value:
                                    '₹${order.totalPrice.toStringAsFixed(2)}',
                                icon:
                                    Icons.currency_rupee,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Row(
                    children: [
                      if (order.dispatchedOn !=
                          null)
                        Expanded(
                          child: Text(
                            'Dispatched on ${order.dispatchedOn}',
                            style:
                                const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                ),
                          ),
                        )
                      else
                        const Spacer(),

                      const Text(
                        'View Details',
                        style: TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        width: 6,
                      ),

                      const Icon(
                        Icons
                            .arrow_forward_ios,
                        size: 14,
                      ),
                    ],
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

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(
            context,
          ).colorScheme.primary,
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}