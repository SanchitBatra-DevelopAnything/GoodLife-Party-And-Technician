import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/screens/full_screen_image_screen.dart';
import 'package:goodlife_party/screens/pdf_viewer_screen.dart';
import 'package:provider/provider.dart';

import '../models/custom_order_model.dart';
import '../providers/auth_provider.dart';

class CustomOrderDetailsScreen extends StatelessWidget {
  final CustomOrderModel order;

  const CustomOrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final allowPayLater =
        context.watch<AuthProvider>().allowPayLater;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),

            const SizedBox(height: 20),

            if (order.requestedItems.isNotEmpty) ...[
              _buildSectionTitle(
                'Requested Items',
              ),

              const SizedBox(height: 12),

              _buildRequestedItems(context),

              const SizedBox(height: 24),
            ],

            if (order.requestedMessage != null &&
                order.requestedMessage!
                    .trim()
                    .isNotEmpty) ...[
              _buildSectionTitle(
                'Request Message',
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Text(
                    order.requestedMessage!,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],

            _buildSectionTitle(
              'Order Information',
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Order Date',
                      order.orderDate,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Order Time',
                      order.orderTime,
                    ),
                  ],
                ),
              ),
            ),

            if (order.additionalDocuments
                .isNotEmpty) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(
                'Additional Documents',
              ),

              const SizedBox(height: 12),

              ...order.additionalDocuments
                  .asMap()
                  .entries
                  .map(
                    (entry) =>
                        _buildDocumentTile(
                      context: context,
                      title:
                          'Document ${entry.key + 1}',
                      url: entry.value,
                      isPdf: true,
                    ),
                  ),
            ],

            if (_shouldShowPi()) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(
                'Proforma Invoice',
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Goodlife has provided a PI for this inquiry.',
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PdfViewerScreen(
                                title:
                                    'Proforma Invoice',
                                pdfUrl:
                                    order.piLink!,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'VIEW PI',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_shouldShowPo()) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(
                'Purchase Order',
              ),

              const SizedBox(height: 12),

              _buildDocumentTile(
                context: context,
                title: 'View PO',
                url: order.poLink!,
                isPdf: true,
              ),
            ],

            if (_shouldShowPayment()) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(
                'Payment Screenshot',
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FullScreenImageScreen(
                        imageUrl:
                            order.paymentLink!,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl:
                        order.paymentLink!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) =>
                            const SizedBox(
                      height: 220,
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget:
                        (context, url, error) =>
                            const SizedBox(
                      height: 220,
                      child: Center(
                        child: Icon(
                          Icons
                              .broken_image_outlined,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Text(
                  _getStatusMessage(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (order.orderStatus ==
                'WAITING_ON_CUSTOMER')
              _buildActionSection(
                context,
                allowPayLater,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                order.orderStatus,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestedItems(
      BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount:
          order.requestedItems.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final image =
            order.requestedItems[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    FullScreenImageScreen(
                  imageUrl: image,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) =>
                      const Center(
                child:
                    CircularProgressIndicator(),
              ),
              errorWidget:
                  (context, url, error) =>
                      const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(title),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
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
        leading:
            const Icon(Icons.description),
        title: Text(title),
        trailing:
            const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerScreen(
                title: title,
                pdfUrl: url,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    bool allowPayLater,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          allowPayLater
              ? 'Please complete the payment or attach the PO to confirm the order.'
              : 'Please complete the payment to confirm the order.',
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text(
              'PAY NOW',
            ),
          ),
        ),

        if (allowPayLater) ...[
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text(
                'ATTACH PO',
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _shouldShowPi() {
    return order.piLink != null &&
        order.piLink!.isNotEmpty;
  }

  bool _shouldShowPo() {
    return order.poLink != null &&
        order.poLink!.isNotEmpty;
  }

  bool _shouldShowPayment() {
    return order.paymentLink != null &&
        order.paymentLink!.isNotEmpty;
  }

  String _getStatusMessage() {
    switch (order.orderStatus) {
      case 'INQUIRY':
        return 'Goodlife is yet to provide a PI for this order. Once they provide a PI, you will be notified.';

      case 'WAITING_ON_CUSTOMER':
        return 'Please complete the payment or attach the PO to confirm the order.';

      case 'PAYMENT_VERIFICATION':
        return 'Your payment is getting verified currently. Order will be dispatched once the payment is verified.';

      case 'PAYMENT_REJECTED':
        return 'Payment is rejected. Please contact Goodlife if you have any concerns or re-place the order with correct payment data.';

      case 'PAYMENT_VERIFIED':
        return 'Payment details are verified. Order will be dispatched soon.';

      case 'DISPATCHED':
        return 'This order is dispatched.';

      default:
        return '';
    }
  }
}