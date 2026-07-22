import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/screens/full_screen_image_screen.dart';
import 'package:goodlife_party/screens/pdf_viewer_screen.dart';
import 'package:goodlife_party/widgets/custom_order_payment_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../models/custom_order_model.dart';
import '../providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/audio_player_widget.dart';

class CustomOrderDetailsScreen extends StatelessWidget {
  final CustomOrderModel order;

  const CustomOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allowPayLater = context.watch<AuthProvider>().allowPayLater;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderDetailsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(l10n),

            const SizedBox(height: 20),

            if (order.requestedItems.isNotEmpty) ...[
              _buildSectionTitle(l10n.requestedItems),

              const SizedBox(height: 12),

              _buildRequestedItems(context),

              const SizedBox(height: 24),
            ],

            if (order.audioUrl != null && order.audioUrl!.isNotEmpty) ...[
              _buildSectionTitle(l10n.voiceNote),
              const SizedBox(height: 12),
              AudioPlayerWidget(audioUrl: order.audioUrl!),
              const SizedBox(height: 24),
            ],

            if (order.requestedMessage != null &&
                order.requestedMessage!.trim().isNotEmpty) ...[
              _buildSectionTitle(l10n.requestMessage),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(order.requestedMessage!),
                ),
              ),

              const SizedBox(height: 24),
            ],

            _buildSectionTitle(l10n.orderInformation),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(l10n.orderDateStr, order.orderDate),
                    const SizedBox(height: 12),
                    _buildInfoRow(l10n.orderTimeStr, order.orderTime),
                  ],
                ),
              ),
            ),

            if (order.additionalDocuments.isNotEmpty) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(l10n.additionalDocuments),

              const SizedBox(height: 12),

              ...order.additionalDocuments.asMap().entries.map((entry) {
                final document = entry.value;

                return _buildDocumentTile(
                  context: context,
                  title: l10n.documentNumber(entry.key + 1),
                  url: document.url,
                  isPdf: document.type == 'pdf',
                );
              }),
            ],

            if (_shouldShowPi()) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(l10n.proformaInvoice),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.piProvidedMsg,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                title: l10n.proformaInvoice,
                                pdfUrl: order.piLink!,
                              ),
                            ),
                          );
                        },
                        child: Text(l10n.viewPi),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_shouldShowPo()) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(l10n.purchaseOrder),

              const SizedBox(height: 12),

              _buildDocumentTile(
                context: context,
                title: l10n.viewPo,
                url: order.poLink!,
                isPdf: true,
              ),
            ],

            if (_shouldShowPayment()) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(l10n.paymentScreenshot),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FullScreenImageScreen(imageUrl: order.paymentLink!),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: order.paymentLink!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      height: 220,
                      child: Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_getStatusMessage(l10n)),
              ),
            ),

            const SizedBox(height: 24),

            if (order.orderStatus == 'WAITING_ON_CUSTOMER')
              _buildActionSection(context, allowPayLater, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getStatusMessage(l10n),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestedItems(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.requestedItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final image = order.requestedItems[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageScreen(imageUrl: image),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDocumentTile({
    required BuildContext context,
    required String title,
    required String url,
    required bool isPdf,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(isPdf ? Icons.picture_as_pdf : Icons.image),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => isPdf
                  ? PdfViewerScreen(title: title, pdfUrl: url)
                  : FullScreenImageScreen(imageUrl: url),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, bool allowPayLater, AppLocalizations l10n) {
    final isLoading = context.watch<OrderProvider>().isPlacingOrder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          allowPayLater
              ? l10n.statusWaitingOnCustomer
              : l10n.completePaymentToConfirm,
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) {
                  return CustomOrderPaymentBottomSheet(
                    firebaseOrderId: order.firebaseOrderId!,
                    partyName: order.orderedBy,
                  );
                },
              );

              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: Text(l10n.payNow),
          ),
        ),

        if (allowPayLater) ...[
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                        withData: true,
                      );

                      if (result == null ||
                          result.files.isEmpty ||
                          result.files.first.bytes == null) {
                        return;
                      }

                      final file = result.files.first;

                      try {
                        await context.read<OrderProvider>().attachPurchaseOrder(
                          firebaseOrderId: order.firebaseOrderId!,
                          partyName: order.orderedBy,
                          pdfBytes: file.bytes!,
                          fileName: file.name,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.poUploadedSuccess),
                            ),
                          );

                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(),
                    )
                  : Text(l10n.attachPo),
            ),
          ),
        ],
      ],
    );
  }

  bool _shouldShowPi() {
    return order.piLink != null && order.piLink!.isNotEmpty;
  }

  bool _shouldShowPo() {
    return order.poLink != null && order.poLink!.isNotEmpty;
  }

  bool _shouldShowPayment() {
    return order.paymentLink != null && order.paymentLink!.isNotEmpty;
  }

  String _getStatusMessage(AppLocalizations l10n) {
    switch (order.orderStatus) {
      case 'INQUIRY':
        return l10n.statusInquiry;

      case 'WAITING_ON_CUSTOMER':
        return l10n.statusWaitingOnCustomer;

      case 'PAYMENT_VERIFICATION':
        return l10n.statusPaymentVerification;

      case 'PAYMENT_REJECTED':
        return l10n.statusPaymentRejected;

      case 'PAYMENT_VERIFIED':
        return l10n.statusPaymentVerified;

      case 'DISPATCHED':
        return l10n.statusDispatched;

      default:
        return '';
    }
  }
}
