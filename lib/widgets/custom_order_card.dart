import 'package:flutter/material.dart';
import '../models/custom_order_model.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final state =
        _getDisplayState(l10n);

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
                    Icons.camera_outlined,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      l10n.customOrderTitle,
                      style:
                          const TextStyle(
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
                l10n.photosUploadedCount(order.requestedItems.length),
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
      _getDisplayState(AppLocalizations l10n) {
    switch (
        order.orderStatus) {
      case 'WAITING_ON_CUSTOMER':
        return _DisplayState(
          l10n.quotationReady,
          l10n.quotationReadyDesc,
          Colors.orange,
        );

      case 'PAYMENT_VERIFICATION':
        return _DisplayState(
          l10n.verificationInProgress,
          l10n.verificationInProgressDesc,
          Colors.blue,
        );

      case 'PAYMENT_VERIFIED':
        return _DisplayState(
          l10n.orderConfirmed,
          l10n.orderConfirmedDesc,
          Colors.green,
        );

      case 'PAYMENT_REJECTED':
        return _DisplayState(
          l10n.actionRequired,
          l10n.paymentRejectedDesc,
          Colors.red,
        );

      case 'DISPATCHED':
        return _DisplayState(
          l10n.dispatched,
          l10n.dispatchedDesc,
          Colors.teal,
        );

      default:
        return _DisplayState(
          l10n.awaitingQuotation,
          l10n.awaitingQuotationDesc,
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