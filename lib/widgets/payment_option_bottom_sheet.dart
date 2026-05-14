import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/providers/cart_provider.dart';
import 'package:goodlife_party/providers/order_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class PaymentOptionBottomSheet extends StatefulWidget {
  final double grandTotal;

  const PaymentOptionBottomSheet({
    super.key,
    required this.grandTotal,
  });

  @override
  State<PaymentOptionBottomSheet>
  createState() =>
      PaymentOptionBottomSheetState();
}

class PaymentOptionBottomSheetState
    extends State<
        PaymentOptionBottomSheet> {
  File? paymentScreenshot;

  final ImagePicker imagePicker =
      ImagePicker();

  Future<void> pickImage() async {
    final pickedFile =
        await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        paymentScreenshot =
            File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS =
        Theme.of(context).platform ==
            TargetPlatform.iOS;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom:
              MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                  20,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Payment Option',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding:
                  const EdgeInsets.all(
                14,
              ),
              decoration:
                  BoxDecoration(
                color: Colors
                    .orange
                    .shade50,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: const Text(
                'Your order will be processed only after the payment is received and verified.\n\nPlease make sure to attach the payment screenshot after completing the payment.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true,
                    shape:
                        const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(
                        top: Radius.circular(
                          24,
                        ),
                      ),
                    ),
                    builder:
                        (context) {
                      return PaymentMethodBottomSheet(
                        onImageSelected:
                            (image) {
                          paymentScreenshot =
                              image;
                        },
                      );
                    },
                  );
                },
                child: const Text(
                  'Pay Now',
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );

                  if (isIOS) {
                    showCupertinoDialog(
                      context: context,
                      builder:
                          (
                            context,
                          ) {
                        return CupertinoAlertDialog(
                          title:
                              const Text(
                            'Pay Later',
                          ),
                          content:
                              const Padding(
                            padding:
                                EdgeInsets.only(
                              top: 12,
                            ),
                            child: Text(
                              'Your order will only be processed after payment verification.',
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child:
                                  const Text(
                                'OK',
                              ),
                              onPressed:
                                  () async {
                                Navigator.pop(
                                  context,
                                );

                                try {
                                  final orderProvider =
                                      Provider.of<
                                        OrderProvider
                                      >(
                                    context,
                                    listen:
                                        false,
                                  );

                                  final cartProvider =
                                      Provider.of<
                                        CartProvider
                                      >(
                                    context,
                                    listen:
                                        false,
                                  );

                                  await orderProvider
                                      .placeOrder(
                                    cartProvider:
                                        cartProvider,
                                    paymentDone:
                                        false,
                                  );

                                  if (!mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text(
                                        'Order placed successfully',
                                      ),
                                    ),
                                  );

                                  Navigator.pop(
                                    context,
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(
                                        'Failed to place order: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder:
                          (
                            context,
                          ) {
                        return AlertDialog(
                          title:
                              const Text(
                            'Pay Later',
                          ),
                          content:
                              const Text(
                            'Your order will only be processed after payment verification.',
                          ),
                          actions: [
                            TextButton(
                              onPressed:
                                  () async {
                                Navigator.pop(
                                  context,
                                );

                                try {
                                  final orderProvider =
                                      Provider.of<
                                        OrderProvider
                                      >(
                                    context,
                                    listen:
                                        false,
                                  );

                                  final cartProvider =
                                      Provider.of<
                                        CartProvider
                                      >(
                                    context,
                                    listen:
                                        false,
                                  );

                                  await orderProvider
                                      .placeOrder(
                                    cartProvider:
                                        cartProvider,
                                    paymentDone:
                                        false,
                                  );

                                  if (!mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text(
                                        'Order placed successfully',
                                      ),
                                    ),
                                  );

                                  Navigator.pop(
                                    context,
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(
                                        'Failed to place order: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child:
                                  const Text(
                                'OK',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text(
                  'Pay Later',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodBottomSheet
    extends StatefulWidget {
  final Function(File image)
      onImageSelected;

  const PaymentMethodBottomSheet({
    super.key,
    required this.onImageSelected,
  });

  @override
  State<PaymentMethodBottomSheet>
  createState() =>
      PaymentMethodBottomSheetState();
}

class PaymentMethodBottomSheetState
    extends State<
        PaymentMethodBottomSheet> {
  bool isUploading = false;

  double uploadProgress = 0;

  String? uploadedImageUrl;

  File? paymentScreenshot;

  final ImagePicker imagePicker =
      ImagePicker();

  Future<void>
  uploadPaymentScreenshot() async {
    if (paymentScreenshot == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please attach payment screenshot',
          ),
        ),
      );

      return;
    }

    try {
      setState(() {
        isUploading = true;
        uploadProgress = 0;
      });

      final paymentUuid =
          const Uuid().v4();

      final now = DateTime.now();

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storagePath =
          '${now.year}/${now.month}/${now.day}/$paymentUuid/$fileName';

      final firebaseStorage =
          FirebaseStorage.instance;

      final uploadTask =
          firebaseStorage
              .ref(storagePath)
              .putFile(
                paymentScreenshot!,
              );

      uploadTask.snapshotEvents
          .listen(
        (
          TaskSnapshot snapshot,
        ) {
          final progress =
              snapshot
                      .bytesTransferred /
                  snapshot
                      .totalBytes;

          setState(() {
            uploadProgress =
                progress * 100;
          });
        },
      );

      final snapshot =
          await uploadTask;

      final downloadUrl =
          await snapshot.ref
              .getDownloadURL();

      setState(() {
        uploadedImageUrl =
            downloadUrl;
      });

      final orderProvider =
          Provider.of<
            OrderProvider
          >(
        context,
        listen: false,
      );

      final cartProvider =
          Provider.of<
            CartProvider
          >(
        context,
        listen: false,
      );

      await orderProvider.placeOrder(
        cartProvider:
            cartProvider,
        paymentDone: true,
        paymentScreenshotUrl:
            uploadedImageUrl,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Order placed successfully',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Upload failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        paymentScreenshot =
            File(pickedFile.path);
      });

      widget.onImageSelected(
        File(pickedFile.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider =
        Provider.of<OrderProvider>(
      context,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom:
              MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                  20,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding:
                  EdgeInsets.zero,
              leading: const Icon(
                Icons.qr_code,
              ),
              title:
                  const Text(
                'QR Code',
              ),
              trailing: const Icon(
                Icons
                    .arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const QRCodeScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              contentPadding:
                  EdgeInsets.zero,
              leading: const Icon(
                Icons
                    .account_balance,
              ),
              title:
                  const Text(
                'Bank Transfer',
              ),
              trailing: const Icon(
                Icons
                    .arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const BankTransferScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Attach Payment Screenshot',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                width:
                    double.infinity,
                height: 140,
                decoration:
                    BoxDecoration(
                  border: Border.all(
                    color: Colors
                        .grey
                        .shade400,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child:
                    paymentScreenshot ==
                            null
                        ? Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: const [
                              Icon(
                                Icons
                                    .upload_file,
                                size:
                                    34,
                              ),
                              SizedBox(
                                height:
                                    10,
                              ),
                              Text(
                                'Upload Screenshot',
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                            child:
                                Image.file(
                              paymentScreenshot!,
                              fit: BoxFit
                                  .cover,
                            ),
                          ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width:
                  double.infinity,
              height: 55,
              child:
                  ElevatedButton(
                onPressed:
                    isUploading ||
                            orderProvider
                                .isPlacingOrder
                        ? null
                        : uploadPaymentScreenshot,

                child:
                    isUploading ||
                            orderProvider
                                .isPlacingOrder
                        ? Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              SizedBox(
                                height:
                                    20,
                                width:
                                    20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2.5,
                                  value:
                                      uploadProgress /
                                      100,
                                  color:
                                      Colors.white,
                                ),
                              ),

                              const SizedBox(
                                height:
                                    6,
                              ),

                              Text(
                                '${uploadProgress.toStringAsFixed(0)}% Uploading',
                              ),
                            ],
                          )
                        : const Text(
                            'Submit Payment',
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRCodeScreen
    extends StatelessWidget {
  const QRCodeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code Payment',
        ),
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Image.asset(
            'assets/images/qr_code.png',
          ),
        ),
      ),
    );
  }
}

class BankTransferScreen
    extends StatelessWidget {
  const BankTransferScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bank Transfer',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: const [
            Text(
              'Account Name',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'Good Life Party',
            ),

            SizedBox(height: 20),

            Text(
              'Account Number',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(height: 6),

            Text(
              '1234567890',
            ),

            SizedBox(height: 20),

            Text(
              'IFSC Code',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'SBIN0001234',
            ),

            SizedBox(height: 20),

            Text(
              'Bank Name',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'State Bank of India',
            ),
          ],
        ),
      ),
    );
  }
}