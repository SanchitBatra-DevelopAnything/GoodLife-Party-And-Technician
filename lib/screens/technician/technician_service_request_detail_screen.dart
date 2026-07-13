import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/service_request_model.dart';
import '../../providers/technician_service_request_provider.dart';
import '../../utils/service_request_status_helper.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/technician/image_upload_grid.dart';
import '../../widgets/technician/technician_curved_app_bar.dart';
import '../full_screen_image_screen.dart';

class TechnicianServiceRequestDetailScreen extends StatefulWidget {
  final ServiceRequestModel request;

  const TechnicianServiceRequestDetailScreen({
    super.key,
    required this.request,
  });

  @override
  State<TechnicianServiceRequestDetailScreen> createState() =>
      _TechnicianServiceRequestDetailScreenState();
}

class _TechnicianServiceRequestDetailScreenState
    extends State<TechnicianServiceRequestDetailScreen> {
  late ServiceRequestModel _request;
  late final AudioPlayer _audioPlayer;

  bool _serviceDone = false;
  bool _cleaningDone = false;
  String? _paymentMode;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _happyCodeController = TextEditingController();

  final List<File> _preWorkLocal = [];
  final List<File> _postWorkLocal = [];
  final List<File> _serviceReportLocal = [];
  final List<File> _googleReviewLocal = [];
  final List<File> _paymentReceiptLocal = [];

  List<String> _preWorkRemote = [];
  List<String> _postWorkRemote = [];
  String? _serviceReportRemote;
  String? _googleReviewRemote;
  String? _paymentReceiptRemote;

  bool _isPlaying = false;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  bool _isClosing = false;
  String _progressMessage = '';

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;

  bool get _isEditable => _request.isActive;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    _serviceDone = _request.serviceDone;
    _cleaningDone = _request.cleaningDone;
    _paymentMode = _request.paymentMode;
    if (_request.paymentAmount != null) {
      _amountController.text = _request.paymentAmount!.toStringAsFixed(0);
    }
    _preWorkRemote = List.from(_request.preWorkImageUrls);
    _postWorkRemote = List.from(_request.postWorkImageUrls);
    _serviceReportRemote = _request.serviceReportImageUrl;
    _googleReviewRemote = _request.googleReviewImageUrl;
    _paymentReceiptRemote = _request.paymentReceiptImageUrl;

    _audioPlayer = AudioPlayer();
    _positionSub = _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _playbackPosition = pos);
    });
    _durationSub = _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _playbackDuration = dur);
    });
    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _audioPlayer.dispose();
    _amountController.dispose();
    _happyCodeController.dispose();
    super.dispose();
  }

  Future<void> _callParty() async {
    final uri = Uri.parse('tel:${_request.contact}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMaps() async {
    final query = Uri.encodeComponent(_request.displayAddress);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _togglePlayback() async {
    final url = _request.audioUrl;
    if (url == null || url.isEmpty) return;
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final s = d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<List<String>> _uploadFiles(List<File> files, String prefix) async {
    final provider = context.read<TechnicianServiceRequestProvider>();
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      setState(() => _progressMessage = 'Uploading $prefix ${i + 1} of ${files.length}...');
      urls.add(await provider.uploadImage(files[i]));
    }
    return urls;
  }

  bool get _hasPreWorkImages =>
      _preWorkRemote.isNotEmpty || _preWorkLocal.isNotEmpty;

  bool get _hasPostWorkImages =>
      _postWorkRemote.isNotEmpty || _postWorkLocal.isNotEmpty;

  bool get _hasServiceReport =>
      _serviceReportRemote != null || _serviceReportLocal.isNotEmpty;

  bool get _hasPaymentReceipt =>
      _paymentReceiptRemote != null || _paymentReceiptLocal.isNotEmpty;

  bool get _isUpiSelected => _paymentMode == 'UPI';

  String? _validateMandatoryFields({bool requirePayment = false}) {
    if (!_hasPreWorkImages) {
      return 'Please upload at least one pre-work image';
    }
    if (!_hasPostWorkImages) {
      return 'Please upload at least one post-work image';
    }
    if (!_hasServiceReport) {
      return 'Please upload the service report image';
    }
    if (!_serviceDone) {
      return 'Please mark Service Done';
    }
    if (!_cleaningDone) {
      return 'Please mark Cleaning Done';
    }
    if (requirePayment) {
      if (_paymentMode == null) {
        return 'Please select a payment mode';
      }
      final amount = double.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) {
        return 'Please enter a valid amount collected';
      }
      if (_isUpiSelected && !_hasPaymentReceipt) {
        return 'Please upload the UPI payment receipt';
      }
    }
    return null;
  }

  Future<ServiceRequestModel> _buildUpdatedRequest({
    String? statusOverride,
  }) async {
    final preUrls = [
      ..._preWorkRemote,
      ...await _uploadFiles(_preWorkLocal, 'pre-work image'),
    ];
    final postUrls = [
      ..._postWorkRemote,
      ...await _uploadFiles(_postWorkLocal, 'post-work image'),
    ];

    String? reportUrl = _serviceReportRemote;
    if (_serviceReportLocal.isNotEmpty) {
      final uploaded = await _uploadFiles(_serviceReportLocal, 'service report');
      reportUrl = uploaded.first;
    }

    String? reviewUrl = _googleReviewRemote;
    if (_googleReviewLocal.isNotEmpty) {
      final uploaded = await _uploadFiles(_googleReviewLocal, 'review image');
      reviewUrl = uploaded.first;
    }

    String? receiptUrl = _paymentReceiptRemote;
    if (_paymentReceiptLocal.isNotEmpty) {
      final uploaded = await _uploadFiles(_paymentReceiptLocal, 'payment receipt');
      receiptUrl = uploaded.first;
    }

    final amount = double.tryParse(_amountController.text.trim());

    return _request.copyWith(
      preWorkImageUrls: preUrls,
      postWorkImageUrls: postUrls,
      serviceDone: _serviceDone,
      cleaningDone: _cleaningDone,
      serviceReportImageUrl: reportUrl,
      googleReviewImageUrl: reviewUrl,
      paymentReceiptImageUrl: _isUpiSelected ? receiptUrl : null,
      paymentMode: _paymentMode,
      paymentAmount: amount,
      status: statusOverride ?? _request.status,
    );
  }

  Future<void> _closeTicket() async {
    final validationError = _validateMandatoryFields(requirePayment: true);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    final happyCode = _happyCodeController.text.trim();
    if (happyCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the Happy Code')),
      );
      return;
    }

    setState(() {
      _isClosing = true;
      _progressMessage = 'Validating Happy Code...';
    });
    try {
      final provider = context.read<TechnicianServiceRequestProvider>();
      final isValid = await provider.validateHappyCodeOnly(
        request: _request,
        happyCode: happyCode,
      );

      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid Happy Code. Ticket not closed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final amount = double.parse(_amountController.text.trim());
      
      final updated = await _buildUpdatedRequest(statusOverride: 'CLOSED');
      
      setState(() {
        _progressMessage = 'Saving updates...';
      });
      _request = await provider.saveWorkUpdate(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket closed — pending admin verification'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to close ticket. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isClosing = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED':
      case 'CLOSED_BY_ADMIN':
        return Colors.green;
      case 'CLOSED':
        return Colors.purple;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'TECHNICIAN_ASSIGNED':
      case 'APPROVED':
        return Colors.teal;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final statusColor = _statusColor(_request.status);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: TechnicianCurvedAppBar(
            title: 'Request Details',
            subtitle: _request.orderedBy,
          ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(primary, statusColor),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: 'Customer Request (View Only)',
              icon: Icons.visibility_rounded,
              children: [
                _infoRow(Icons.store_rounded, 'Party / User', _request.orderedBy),
                const SizedBox(height: 10),
                _tapRow(
                  icon: Icons.phone_rounded,
                  label: 'Mobile',
                  value: _request.contact,
                  onTap: _callParty,
                  actionIcon: Icons.call_rounded,
                ),
                const SizedBox(height: 10),
                _tapRow(
                  icon: Icons.location_on_rounded,
                  label: 'Address',
                  value: _request.displayAddress,
                  onTap: _openMaps,
                  actionIcon: Icons.map_rounded,
                  multiline: true,
                ),
                if (_request.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.notes_rounded,
                    'Description',
                    _request.description,
                    multiline: true,
                  ),
                ],
                if (_request.audioUrl != null &&
                    _request.audioUrl!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildAudioPlayer(primary),
                ],
                if (_request.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildUserImages(),
                ],
              ],
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: 'Technician Actions',
              icon: Icons.build_rounded,
              children: [
                ImageUploadGrid(
                  title: 'Pre-work Images *',
                  maxImages: 4,
                  localImages: _preWorkLocal,
                  remoteUrls: _preWorkRemote,
                  enabled: _isEditable,
                  onImageAdded: (f) => setState(() => _preWorkLocal.add(f)),
                  onImageRemoved: (index, isLocal) {
                    setState(() {
                      if (isLocal) {
                        _preWorkLocal.removeAt(index);
                      } else {
                        _preWorkRemote.removeAt(index);
                      }
                    });
                  },
                ),
                const SizedBox(height: 18),
                ImageUploadGrid(
                  title: 'Post-work Images *',
                  maxImages: 4,
                  localImages: _postWorkLocal,
                  remoteUrls: _postWorkRemote,
                  enabled: _isEditable,
                  onImageAdded: (f) => setState(() => _postWorkLocal.add(f)),
                  onImageRemoved: (index, isLocal) {
                    setState(() {
                      if (isLocal) {
                        _postWorkLocal.removeAt(index);
                      } else {
                        _postWorkRemote.removeAt(index);
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Service Done *'),
                  value: _serviceDone,
                  onChanged: _isEditable
                      ? (v) => setState(() => _serviceDone = v ?? false)
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Cleaning Done *'),
                  value: _cleaningDone,
                  onChanged: _isEditable
                      ? (v) => setState(() => _cleaningDone = v ?? false)
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 8),
                ImageUploadGrid(
                  title: 'Service Report Image *',
                  maxImages: 1,
                  localImages: _serviceReportLocal,
                  remoteUrls: _serviceReportRemote != null
                      ? [_serviceReportRemote!]
                      : [],
                  enabled: _isEditable,
                  onImageAdded: (f) => setState(() {
                    _serviceReportLocal
                      ..clear()
                      ..add(f);
                  }),
                  onImageRemoved: (_, isLocal) {
                    setState(() {
                      if (isLocal) {
                        _serviceReportLocal.clear();
                      } else {
                        _serviceReportRemote = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 18),
                _buildPaymentSection(),
                if (_isUpiSelected) ...[
                  const SizedBox(height: 18),
                  _buildUpiPaymentQr(primary),
                  const SizedBox(height: 18),
                  ImageUploadGrid(
                    title: 'Payment Receipt *',
                    maxImages: 1,
                    localImages: _paymentReceiptLocal,
                    remoteUrls: _paymentReceiptRemote != null
                        ? [_paymentReceiptRemote!]
                        : [],
                    enabled: _isEditable,
                    onImageAdded: (f) => setState(() {
                      _paymentReceiptLocal
                        ..clear()
                        ..add(f);
                    }),
                    onImageRemoved: (_, isLocal) {
                      setState(() {
                        if (isLocal) {
                          _paymentReceiptLocal.clear();
                        } else {
                          _paymentReceiptRemote = null;
                        }
                      });
                    },
                  ),
                ],
                const SizedBox(height: 18),
                _buildGoogleReviewSection(primary),
                if (_isEditable) ...[
                  const SizedBox(height: 24),
                  _buildCloseSection(primary),
                ],
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
    if (_isClosing)
      TechnicianRequestLoader(
        message: _progressMessage,
      ),
    ],
  );
}

  Widget _buildStatusCard(Color primary, Color statusColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _badgeColumn('Type', _request.type == 'INSTALLATION' ? 'Installation' : 'Service', primary),
            Container(width: 1, height: 40, color: Colors.grey.shade200),
            _badgeColumn(
              'Status',
              ServiceRequestStatusHelper.technicianListLabel(_request.status),
              statusColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool multiline = false}) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _tapRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData actionIcon,
    bool multiline = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: multiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: Text(label,
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  )),
            ),
            Icon(actionIcon,
                size: 20, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Voice Note',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                color: primary,
                size: 40,
              ),
              onPressed: _togglePlayback,
            ),
            Expanded(
              child: Column(
                children: [
                  Slider(
                    min: 0,
                    max: _playbackDuration.inMilliseconds.toDouble() > 0
                        ? _playbackDuration.inMilliseconds.toDouble()
                        : 1,
                    value: _playbackPosition.inMilliseconds
                        .toDouble()
                        .clamp(0, _playbackDuration.inMilliseconds.toDouble()),
                    activeColor: primary,
                    onChanged: (v) =>
                        _audioPlayer.seek(Duration(milliseconds: v.toInt())),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_playbackPosition),
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600)),
                      Text(_formatDuration(_playbackDuration),
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer Images',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _request.imageUrls.map((url) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageScreen(imageUrl: url),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUpiPaymentQr(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'UPI Payment QR',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Scan using PhonePe, Google Pay, Paytm, BHIM or any UPI app',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/qr_code.jpeg',
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          const SelectableText(
            'goodlife32461@fbl',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleReviewSection(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Google Review QR Code',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Show this QR code to the customer to leave a Google review.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/Google_Review_QR.png',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ImageUploadGrid(
            title: 'Google Review Image (Optional)',
            maxImages: 1,
            localImages: _googleReviewLocal,
            remoteUrls:
                _googleReviewRemote != null ? [_googleReviewRemote!] : [],
            enabled: _isEditable,
            onImageAdded: (f) => setState(() {
              _googleReviewLocal
                ..clear()
                ..add(f);
            }),
            onImageRemoved: (_, isLocal) {
              setState(() {
                if (isLocal) {
                  _googleReviewLocal.clear();
                } else {
                  _googleReviewRemote = null;
                }
              });
            },
          ),
        ],
      ),
    );
  }
  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Collection',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('UPI'),
                selected: _paymentMode == 'UPI',
                onSelected: _isEditable
                    ? (s) => setState(() {
                          _paymentMode = s ? 'UPI' : null;
                          if (!s) {
                            _paymentReceiptLocal.clear();
                            _paymentReceiptRemote = null;
                          }
                        })
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Text('Cash'),
                selected: _paymentMode == 'CASH',
                onSelected: _isEditable
                    ? (s) => setState(() {
                          _paymentMode = s ? 'CASH' : null;
                          _paymentReceiptLocal.clear();
                          _paymentReceiptRemote = null;
                        })
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          enabled: _isEditable,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Amount Collected (₹)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_rupee_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseSection(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded, color: primary),
              const SizedBox(width: 8),
              const Text('Close Ticket',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ask the customer for their Happy Code to close this ticket.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _happyCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Happy Code',
              border: OutlineInputBorder(),
              counterText: '',
              prefixIcon: Icon(Icons.lock_rounded),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            text: _isClosing ? 'Validating...' : 'Validate & Close Ticket',
            onPressed: _isClosing ? null : _closeTicket,
            isIOS: false,
          ),
        ],
      ),
    );
  }
}

class TechnicianRequestLoader extends StatelessWidget {
  final String message;

  const TechnicianRequestLoader({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Processing...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

