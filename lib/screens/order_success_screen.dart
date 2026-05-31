import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Order Placed',
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

              const Text(
                'Your order has been placed successfully!',
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
                    ? 'Your payment screenshot has been uploaded successfully.\n\nYour order is currently under payment verification.\nWe will start processing your order once the payment is verified.'
                    : 'Your order has been placed successfully.\n\nPlease complete your payment soon so that we can start processing your order.\n\nPlease contact us to get your payment verified.',

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

                        title:
                            const Text(
                          'Pay Using QR Code',
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

                        title:
                            const Text(
                          'Bank Transfer Details',
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
                      const Text(
                    'Continue',
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