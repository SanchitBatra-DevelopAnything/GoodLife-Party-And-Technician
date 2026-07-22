import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../widgets/payment_option_bottom_sheet.dart';

class OrderSuccessScreen
    extends StatelessWidget {
  final bool paymentDone;

  const OrderSuccessScreen({
    super.key,
    required this.paymentDone,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.orderPlacedSuccessfullyTitle,
        ),
        automaticallyImplyLeading:
            false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            24,
          ),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,

            children: [
              const SizedBox(
                height: 40,
              ),

              const Icon(
                Icons
                    .check_circle_outline,

                size: 90,

                color: Colors.green,
              ),

              const SizedBox(
                height: 28,
              ),

              Text(
                  l10n.orderPlacedSuccessfullyTitle,
                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 22,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                paymentDone
                    ? l10n.orderPlacedSuccessWithPayment
                    : l10n.orderPlacedSuccessWithoutPayment,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 16,
                  color:
                      Colors.black54,
                  height: 1.6,
                ),
              ),

              if (!paymentDone) ...[
                const SizedBox(
                  height: 36,
                ),

                Container(
                  decoration:
                      BoxDecoration(
                    border: Border.all(
                      color: Colors
                          .grey
                          .shade300,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),

                  child: Column(
                    children: [
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              16,
                          vertical:
                              4,
                        ),

                        leading:
                            const Icon(
                          Icons.qr_code,
                        ),

                        title: Text(
                          l10n.qrCode,
                        ),

                        trailing:
                            const Icon(
                          Icons
                              .arrow_forward_ios,
                          size: 18,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) =>
                                      const QRCodeScreen(),
                            ),
                          );
                        },
                      ),

                      Divider(
                        height: 1,
                        color: Colors
                            .grey
                            .shade300,
                      ),

                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              16,
                          vertical:
                              4,
                        ),

                        leading:
                            const Icon(
                          Icons
                              .account_balance,
                        ),

                        title: Text(
                          l10n.bankTransfer,
                        ),

                        trailing:
                            const Icon(
                          Icons
                              .arrow_forward_ios,
                          size: 18,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) =>
                                      const BankTransferScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(
                height: 50,
              ),

              SizedBox(
                width:
                    double.infinity,

                height: 56,

                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).popUntil(
                      (
                        route,
                      ) =>
                          route
                              .isFirst,
                    );
                  },

                  child:
                      Text(
                  l10n.continueBtn,
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}