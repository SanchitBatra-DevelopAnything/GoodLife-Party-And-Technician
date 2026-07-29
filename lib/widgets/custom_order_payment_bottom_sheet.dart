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


class CustomOrderPaymentBottomSheet extends StatefulWidget {
  final String firebaseOrderId;
  final String partyName;

  const CustomOrderPaymentBottomSheet({
    super.key,
    required this.firebaseOrderId,
    required this.partyName,
  });

  @override
  State<CustomOrderPaymentBottomSheet> createState() =>
      CustomOrderPaymentBottomSheetState();
}

class CustomOrderPaymentBottomSheetState
    extends State<CustomOrderPaymentBottomSheet> {
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

  Future<void> attachPaymentLink(String screenshotUrl) async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      await orderProvider.attachPaymentScreenshotForCustomOrder(
        firebaseOrderId: widget.firebaseOrderId,
        partyName: widget.partyName,
        paymentLink: screenshotUrl,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context , true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.paymentScreenshotUploadedSuccess),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.failedToUploadPayment(e.toString()))),
      );
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
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
    final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.selectPaymentMethod,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                          const Icon(Icons.upload_file, size: 34),
                          const SizedBox(height: 10),
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
                style: const TextStyle(color: Colors.red, fontSize: 13),
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

                        await attachPaymentLink(screenshotUrl);
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

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.qrCodePayment)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.scanQrCodeToPay,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                Text(
                  AppLocalizations.of(context)!.scanUpiHint,
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.bankTransfer)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoTile(
                  title: AppLocalizations.of(context)!.accountName,
                  value: 'GOOD LIFE TECHNOLOGIES PVT LTD',
                ),
                const Divider(),

                _InfoTile(title: AppLocalizations.of(context)!.bankName, value: 'Federal Bank'),
                const Divider(),

                _InfoTile(title: AppLocalizations.of(context)!.branch, value: 'Noida'),
                const Divider(),

                _InfoTile(title: AppLocalizations.of(context)!.accountNumber, value: '134020200032461'),
                const Divider(),

                _InfoTile(title: AppLocalizations.of(context)!.ifscCode, value: 'FDRL0001340'),
                const Divider(),

                _InfoTile(title: AppLocalizations.of(context)!.accountType, value: 'Current'),
                const Divider(),

                _InfoTile(title: AppLocalizations.of(context)!.swiftCode, value: 'FDRLINBBIBD'),
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

  const _InfoTile({required this.title, required this.value});

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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(
            child: SelectableText(value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
