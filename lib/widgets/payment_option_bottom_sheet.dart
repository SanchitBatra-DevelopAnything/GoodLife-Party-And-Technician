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
import '../l10n/app_localizations.dart';

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
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.submissionFailed(e.toString()))));
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
    final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.choosePaymentOption,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),



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
                child: Text(l10n.payNow),
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

  // Pre-upload: the future starts as soon as the image is picked
  Future<String>? _preUploadFuture;

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

      // Use the pre-started upload if available, otherwise upload now
      final String downloadUrl;
      if (_preUploadFuture != null) {
        downloadUrl = await _preUploadFuture!;
      } else {
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
        final uploadTask = firebaseStorage.ref(storagePath).putFile(paymentScreenshot!);
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          if (!mounted) return;
          setState(() { uploadProgress = progress * 100; });
        });
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

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
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.uploadFailed(e.toString()))));

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
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.submissionFailed(e.toString()))));
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        paymentScreenshot = file;
        showScreenshotValidationError = false;
      });
      // Start uploading immediately in the background
      final paymentUuid = const Uuid().v4();
      final now = DateTime.now();
      final fileName = '${now.millisecondsSinceEpoch}.jpg';
      final storagePath = StorageService.buildDateBasedStoragePath(
        category: 'sparePartPayments',
        fileName: fileName,
        intermediateSegments: [paymentUuid],
        dateTime: now,
      );
      _preUploadFuture = FirebaseStorage.instance
          .ref(storagePath)
          .putFile(file)
          .then((snapshot) => snapshot.ref.getDownloadURL());
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final l10n = AppLocalizations.of(context)!;

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
            Text(
              l10n.selectPaymentMethod,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.qr_code),
              title: Text(l10n.qrCode),
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
              title: Text(l10n.bankTransfer),
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

            Text(
              l10n.attachPaymentScreenshot,
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
                        children: [
                          Icon(Icons.upload_file, size: 34),
                          SizedBox(height: 10),
                          Text(l10n.uploadScreenshotHint),
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
              Text(
                l10n.pleaseAttachPaymentScreenshot,
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
                            l10n.uploadingProgress(uploadProgress.toStringAsFixed(0)),
                          ),
                        ],
                      )
                    : Text(l10n.submitPaymentBtn),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanQrCodeToPay),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.scanQrCodeToPay,
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

                Text(
                  l10n.scanUpiHint,
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bankTransfer),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoTile(
                  title: l10n.accountName,
                  value: 'GOOD LIFE TECHNOLOGIES PVT LTD',
                ),
                Divider(),

                _InfoTile(
                  title: l10n.bankName,
                  value: 'Federal Bank',
                ),
                Divider(),

                _InfoTile(
                  title: l10n.branch,
                  value: 'Noida',
                ),
                Divider(),

                _InfoTile(
                  title: l10n.accountNumber,
                  value: '134020200032461',
                ),
                Divider(),

                _InfoTile(
                  title: l10n.ifscCode,
                  value: 'FDRL0001340',
                ),
                Divider(),

                _InfoTile(
                  title: l10n.accountType,
                  value: 'Current',
                ),
                Divider(),

                _InfoTile(
                  title: l10n.swiftCode,
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
