import 'package:flutter/material.dart';
import '../models/custom_order_model.dart';

class CustomOrderCard
    extends StatelessWidget {
  final CustomOrderModel order;
  final VoidCallback onTap;

  const CustomOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state =
        _getDisplayState();

    return Card(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.build,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Expanded(
                    child: Text(
                      'Custom Order',
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons
                        .arrow_forward_ios,
                    size: 16,
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                '${order.orderDate} • ${order.orderTime}',
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                '${order.requestedItems.length} Photos Uploaded',
              ),

              const SizedBox(
                height: 16,
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  color: state.color
                      .withOpacity(
                    0.1,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),
                child: Text(
                  state.title,
                  style: TextStyle(
                    color:
                        state.color,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                state.subtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _DisplayState
      _getDisplayState() {
    switch (
        order.orderStatus) {
      case 'WAITING_ON_CUSTOMER':
        return const _DisplayState(
          'Quotation Ready',
          'Review quotation and upload payment proof.',
          Colors.orange,
        );

      case 'PAYMENT_VERIFICATION':
        return const _DisplayState(
          'Verification In Progress',
          'Payment verification is underway.',
          Colors.blue,
        );

      case 'PAYMENT_VERIFIED':
        return const _DisplayState(
          'Order Confirmed',
          'Your order will be dispatched soon.',
          Colors.green,
        );

      case 'PAYMENT_REJECTED':
        return const _DisplayState(
          'Action Required',
          'Payment was rejected. Please contact support to further process this order.',
          Colors.red,
        );

      case 'DISPATCHED':
        return const _DisplayState(
          'Dispatched',
          'Your order has been dispatched.',
          Colors.teal,
        );

      default:
        return const _DisplayState(
          'Awaiting Quotation',
          'We are preparing your quotation.',
          Colors.orange,
        );
    }
  }
}

class _DisplayState {
  final String title;
  final String subtitle;
  final Color color;

  const _DisplayState(
    this.title,
    this.subtitle,
    this.color,
  );
}