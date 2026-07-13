import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/providers/cart_provider.dart';
import 'package:goodlife_party/providers/order_provider.dart';
import 'package:goodlife_party/screens/order_success_screen.dart';
import 'package:goodlife_party/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class PaymentOptionBottomSheet extends StatefulWidget {
  final double grandTotal;

  const PaymentOptionBottomSheet({super.key, required this.grandTotal});

  @override
  State<PaymentOptionBottomSheet> createState() =>
      PaymentOptionBottomSheetState();
}

class PaymentOptionBottomSheetState extends State<PaymentOptionBottomSheet> {
  bool isPayLaterLoading = false;

  Future<void> placePayLaterOrder() async {
    try {
      setState(() {
        isPayLaterLoading = true;
      });

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      await orderProvider.placeOrder(
        cartProvider: cartProvider,
        paymentDone: false,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const OrderSuccessScreen(paymentDone: false),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isPayLaterLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Payment Option',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Your order will be processed only after the payment is received and verified.\n\nPlease make sure to attach the payment screenshot after completing the payment.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) {
                      return const PaymentMethodBottomSheet();
                    },
                  );
                },
                child: const Text('Pay Now'),
              ),
            ),

            // const SizedBox(height: 14),

            // SizedBox(
            //   width: double.infinity,
            //   height: 55,
            //   child: OutlinedButton(
            //     onPressed: isPayLaterLoading
            //         ? null
            //         : () async {
            //             await placePayLaterOrder();
            //           },
            //     child: isPayLaterLoading
            //         ? const SizedBox(
            //             height: 22,
            //             width: 22,
            //             child: CircularProgressIndicator(strokeWidth: 2.5),
            //           )
            //         : const Text('Pay Later'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodBottomSheet extends StatefulWidget {
  const PaymentMethodBottomSheet({super.key});

  @override
  State<PaymentMethodBottomSheet> createState() =>
      PaymentMethodBottomSheetState();
}

class PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool isUploading = false;

  double uploadProgress = 0;

  String? uploadedImageUrl;

  File? paymentScreenshot;

  bool showScreenshotValidationError = false;

  final ImagePicker imagePicker = ImagePicker();

  Future<String?> uploadPaymentScreenshot() async {
    if (paymentScreenshot == null) {
      setState(() {
        showScreenshotValidationError = true;
      });

      return null;
    }

    try {
      setState(() {
        isUploading = true;
        uploadProgress = 0;
      });

      final paymentUuid = const Uuid().v4();

      final now = DateTime.now();

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storagePath = StorageService.buildDateBasedStoragePath(
        category: 'sparePartPayments',
        fileName: fileName,
        intermediateSegments: [paymentUuid],
        dateTime: now,
      );

      final firebaseStorage = FirebaseStorage.instance;

      final uploadTask = firebaseStorage
          .ref(storagePath)
          .putFile(paymentScreenshot!);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;

        if (!mounted) {
          return;
        }

        setState(() {
          uploadProgress = progress * 100;
        });
      });

      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (!mounted) {
        return null;
      }

      setState(() {
        uploadedImageUrl = downloadUrl;
      });

      return downloadUrl;
    } catch (e) {
      if (!mounted) {
        return null;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));

      return null;
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> submitOrder(String screenshotUrl) async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      await orderProvider.placeOrder(
        cartProvider: cartProvider,
        paymentDone: true,
        paymentScreenshotUrl: screenshotUrl,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderSuccessScreen(paymentDone: true),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        paymentScreenshot = File(pickedFile.path);
        showScreenshotValidationError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.qr_code),
              title: const Text('QR Code'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRCodeScreen()),
                );
              },
            ),

            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance),
              title: const Text('Bank Transfer'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BankTransferScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Attach Payment Screenshot',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 14),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: showScreenshotValidationError
                        ? Colors.red
                        : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: paymentScreenshot == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.upload_file, size: 34),
                          SizedBox(height: 10),
                          Text('Upload Screenshot'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          paymentScreenshot!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            if (showScreenshotValidationError) ...[
              const SizedBox(height: 8),
              const Text(
                'Please attach payment screenshot',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isUploading || orderProvider.isPlacingOrder
                    ? null
                    : () async {
                        final screenshotUrl = await uploadPaymentScreenshot();

                        if (screenshotUrl == null) {
                          return;
                        }

                        await submitOrder(screenshotUrl);
                      },
                child: isUploading || orderProvider.isPlacingOrder
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              value: uploadProgress / 100,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            '${uploadProgress.toStringAsFixed(0)}% Uploading',
                          ),
                        ],
                      )
                    : const Text('Submit Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Payment'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Scan QR Code to Pay',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.9,
                    maxHeight: 500,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.asset(
                        'assets/qr_code.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const SelectableText(
                  'goodlife32461@fbl',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Scan using PhonePe, Google Pay, Paytm, BHIM or any UPI app',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BankTransferScreen extends StatelessWidget {
  const BankTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Transfer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                _InfoTile(
                  title: 'Account Name',
                  value: 'GOOD LIFE TECHNOLOGIES PVT LTD',
                ),
                Divider(),

                _InfoTile(
                  title: 'Bank Name',
                  value: 'Federal Bank',
                ),
                Divider(),

                _InfoTile(
                  title: 'Branch',
                  value: 'Noida',
                ),
                Divider(),

                _InfoTile(
                  title: 'Account Number',
                  value: '134020200032461',
                ),
                Divider(),

                _InfoTile(
                  title: 'IFSC Code',
                  value: 'FDRL0001340',
                ),
                Divider(),

                _InfoTile(
                  title: 'Account Type',
                  value: 'Current',
                ),
                Divider(),

                _InfoTile(
                  title: 'SWIFT Code',
                  value: 'FDRLINBBIBD',
                ),
              ],
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

  const _InfoTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
