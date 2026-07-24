import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodlife_party/models/service_request_model.dart';
import 'package:goodlife_party/providers/auth_provider.dart';
import 'package:goodlife_party/providers/service_request_provider.dart';
import 'package:goodlife_party/screens/full_screen_image_screen.dart';
import 'package:goodlife_party/services/technician_auth_service.dart';
import 'package:goodlife_party/utils/service_request_status_helper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import 'package:goodlife_party/screens/pdf_viewer_screen.dart';

class ServiceRequestDetailsScreen extends StatefulWidget {
  final ServiceRequestModel request;

  const ServiceRequestDetailsScreen({super.key, required this.request});

  @override
  State<ServiceRequestDetailsScreen> createState() =>
      _ServiceRequestDetailsScreenState();
}

class _ServiceRequestDetailsScreenState
    extends State<ServiceRequestDetailsScreen> {
  late ServiceRequestModel _request;
  late final AudioPlayer _audioPlayer;
  final TechnicianAuthService _technicianAuthService = TechnicianAuthService();
  bool _isPlaying = false;
  bool _isRefreshing = false;
  String? _technicianPhone;
  int? _selectedRating;
  final TextEditingController _ratingCommentController =
      TextEditingController();
  bool _isSubmittingRating = false;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  bool get _isInvoicePdf {
    if (_request.invoiceUrl == null || _request.invoiceUrl!.isEmpty)
      return false;
    final urlWithoutQuery = _request.invoiceUrl!.split('?').first.toLowerCase();
    return urlWithoutQuery.endsWith('.pdf');
  }

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    _audioPlayer = AudioPlayer();

    _positionSubscription = _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _playbackPosition = pos;
        });
      }
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _playbackDuration = dur;
        });
      }
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _resolveTechnicianPhone();
      await _refreshRequest();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _ratingCommentController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _refreshRequest() async {
    final partyName = context.read<AuthProvider>().distributorName;
    if (partyName.isEmpty) return;

    setState(() => _isRefreshing = true);
    try {
      final provider = context.read<ServiceRequestProvider>();
      await provider.fetchServiceRequests(partyName);
      ServiceRequestModel? updated;
      for (final r in provider.serviceRequests) {
        if (r.serviceRequestId == _request.serviceRequestId) {
          updated = r;
          break;
        }
      }
      if (updated != null && mounted) {
        setState(() => _request = updated!);
      }
      await _resolveTechnicianPhone();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _resolveTechnicianPhone() async {
    if (!_request.hasAssignedTechnician) {
      if (mounted) setState(() => _technicianPhone = null);
      return;
    }

    final storedPhone = _request.assignedTechnicianPhone?.trim();
    if (storedPhone != null && storedPhone.isNotEmpty) {
      if (mounted) setState(() => _technicianPhone = storedPhone);
      return;
    }

    final fetched = await _technicianAuthService.fetchTechnicianPhoneById(
      _request.assignedTechnicianId!,
    );
    if (mounted) setState(() => _technicianPhone = fetched);
  }

  Future<void> _callTechnician() async {
    final phone = _technicianPhone?.trim();
    if (phone == null || phone.isEmpty) return;

    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _togglePlayback() async {
    final audioUrl = _request.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(audioUrl));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorPlayingAudio(e.toString()))),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submitRating() async {
    final rating = _selectedRating;
    if (rating == null) return;

    setState(() => _isSubmittingRating = true);
    try {
      final provider = context.read<ServiceRequestProvider>();
      final updated = await provider.submitTechnicianRating(
        request: _request,
        rating: rating,
        comment: _ratingCommentController.text,
      );
      if (mounted) {
        setState(() => _request = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.ratingSubmitted),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToSubmitRating),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingRating = false);
    }
  }

  Widget _buildStarRow({
    required int selectedRating,
    required ValueChanged<int> onRatingSelected,
    double size = 36,
    bool readOnly = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= selectedRating;
        return IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(),
          onPressed: readOnly ? null : () => onRatingSelected(starValue),
          icon: Icon(
            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber.shade700,
            size: size,
          ),
        );
      }),
    );
  }

  Widget _buildRatingSection(Color primary, AppLocalizations l10n) {
    if (_request.hasTechnicianRating) {
      return _buildSectionCard(
        title: l10n.yourRating,
        icon: Icons.star_rounded,
        children: [
          _buildStarRow(
            selectedRating: _request.technicianRating!,
            onRatingSelected: (_) {},
            readOnly: true,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ratingStars(_request.technicianRating!),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_request.technicianRatingComment != null &&
              _request.technicianRatingComment!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _request.technicianRatingComment!.trim(),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.ratingThankYou,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green.shade700, fontSize: 13),
          ),
        ],
      );
    }

    if (!_request.canRateTechnician) return const SizedBox.shrink();

    return _buildSectionCard(
      title: l10n.rateTechnician,
      icon: Icons.star_outline_rounded,
      children: [
        Text(
          l10n.rateTechnicianOptional,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (_request.assignedTechnicianName != null &&
            _request.assignedTechnicianName!.isNotEmpty)
          Text(
            _request.assignedTechnicianName!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        const SizedBox(height: 8),
        _buildStarRow(
          selectedRating: _selectedRating ?? 0,
          onRatingSelected: (value) => setState(() => _selectedRating = value),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ratingCommentController,
          maxLines: 3,
          enabled: !_isSubmittingRating,
          decoration: InputDecoration(
            hintText: l10n.ratingCommentHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedRating == null || _isSubmittingRating
                ? null
                : _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isSubmittingRating ? l10n.submittingRating : l10n.submitRating,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _openImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullScreenImageScreen(imageUrl: url)),
    );
  }

  String _getLocalizedStatusLabel(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toUpperCase()) {
      case 'VERIFIED':
        return l10n.statusVerified;
      case 'CLOSED':
        return l10n.statusClosedByTechnician;
      case 'CLOSED_BY_ADMIN':
        return l10n.statusClosed;
      case 'RESOLVED':
        return l10n.statusResolved;
      case 'IN_PROGRESS':
        return l10n.statusInProgress;
      case 'TECHNICIAN_ASSIGNED':
        return l10n.statusAssigned;
      case 'APPROVED':
        return l10n.statusApproved;
      case 'PENDING':
      default:
        return l10n.statusPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = ServiceRequestStatusHelper.color(_request.status);
    final primary = Theme.of(context).colorScheme.primary;
    final machines = _request.machineNames.isNotEmpty
        ? _request.machineNames.join(', ')
        : _request.machineIds.join(', ');
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: BoxDecoration(
            color: primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.requestDetails,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isRefreshing)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _refreshRequest,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                      tooltip: l10n.refresh,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRequest,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.typeLabel,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _request.type == 'INSTALLATION'
                                    ? l10n.installationTab
                                    : l10n.serviceComplaintTab,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.statusLabel,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _getLocalizedStatusLabel(
                                  context,
                                  _request.status,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.requestDetails,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Divider(height: 20),
                      _infoRow(
                        icon: Icons.precision_manufacturing_rounded,
                        label: l10n.assignedMachines,
                        value: machines.isNotEmpty ? machines : '—',
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        icon: Icons.calendar_today_rounded,
                        label: l10n.dateLabel,
                        value: _request.requestDate,
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        icon: Icons.access_time_rounded,
                        label: l10n.timeLabel,
                        value: _request.requestTime,
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        icon: Icons.location_on_rounded,
                        label: l10n.areaLabel,
                        value: _request.area.isNotEmpty ? _request.area : '—',
                      ),
                      if (_request.hasAssignedTechnician) ...[
                        const SizedBox(height: 12),
                        _infoRow(
                          icon: Icons.engineering_rounded,
                          label: l10n.technicianLabel,
                          value:
                              (_request.assignedTechnicianName != null &&
                                  _request.assignedTechnicianName!.isNotEmpty)
                              ? _request.assignedTechnicianName!
                              : l10n.statusAssigned,
                        ),
                        if (_technicianPhone != null &&
                            _technicianPhone!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _technicianContactRow(_technicianPhone!),
                        ],
                      ],
                      if (_request.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _infoRow(
                          icon: Icons.notes_rounded,
                          label: l10n.description,
                          value: _request.description,
                          multiline: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              if (_request.imageUrls.isNotEmpty) ...[
                _buildSectionCard(
                  title: l10n.submittedPhotos,
                  icon: Icons.photo_library_rounded,
                  children: [_buildImageGallery(_request.imageUrls)],
                ),
                const SizedBox(height: 14),
              ],

              if (_request.audioUrl != null &&
                  _request.audioUrl!.isNotEmpty) ...[
                _buildAudioPlayerCard(primary),
                const SizedBox(height: 14),
              ],

              if (_request.preWorkImageUrls.isNotEmpty ||
                  _request.postWorkImageUrls.isNotEmpty) ...[
                _buildSectionCard(
                  title: l10n.technicianWorkPhotos,
                  icon: Icons.camera_alt_rounded,
                  children: [
                    if (_request.preWorkImageUrls.isNotEmpty) ...[
                      _buildImageSectionLabel(l10n.beforeService),
                      const SizedBox(height: 8),
                      _buildImageGallery(_request.preWorkImageUrls),
                    ],
                    if (_request.preWorkImageUrls.isNotEmpty &&
                        _request.postWorkImageUrls.isNotEmpty)
                      const SizedBox(height: 16),
                    if (_request.postWorkImageUrls.isNotEmpty) ...[
                      _buildImageSectionLabel(l10n.afterService),
                      const SizedBox(height: 8),
                      _buildImageGallery(_request.postWorkImageUrls),
                    ],
                    if (_request.isCompleted &&
                        (_request.serviceDone || _request.cleaningDone)) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_request.serviceDone)
                            _buildDoneChip(
                              l10n.serviceDone,
                              Icons.build_rounded,
                            ),
                          if (_request.cleaningDone)
                            _buildDoneChip(
                              l10n.cleaningDone,
                              Icons.cleaning_services_rounded,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
              ],

              if (_request.paymentAmount != null) ...[
                _buildSectionCard(
                  title: l10n.paymentLabel,
                  icon: Icons.payments_rounded,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.currency_rupee_rounded,
                            color: Colors.green,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${_request.paymentAmount!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _request.paymentMode?.toUpperCase() == 'CASH'
                                    ? l10n.paidByCash
                                    : _request.paymentMode?.toUpperCase() ==
                                          'UPI'
                                    ? l10n.paidByUpi
                                    : l10n.paidVia(_request.paymentMode ?? '—'),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_request.paymentReceiptImageUrl != null &&
                        _request.paymentReceiptImageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildImageSectionLabel(l10n.paymentScreenshot),
                      const SizedBox(height: 8),
                      _buildImageGallery([_request.paymentReceiptImageUrl!]),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
              ],

              if (_request.invoiceUrl != null &&
                  _request.invoiceUrl!.isNotEmpty) ...[
                _buildSectionCard(
                  title: l10n.invoiceLabel,
                  icon: Icons.receipt_long_rounded,
                  children: [
                    Text(
                      l10n.invoiceUploadedNotice,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (_isInvoicePdf) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                title: l10n.invoiceLabel,
                                pdfUrl: _request.invoiceUrl!,
                              ),
                            ),
                          );
                        } else {
                          _openImage(_request.invoiceUrl!);
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            if (_isInvoicePdf)
                              Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  size: 64,
                                  color: Colors.red.shade400,
                                ),
                              )
                            else
                              CachedNetworkImage(
                                imageUrl: _request.invoiceUrl!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.black54,
                              child: Text(
                                l10n.tapToViewInvoice,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              if (_request.isCompleted && _request.hasAssignedTechnician) ...[
                _buildRatingSection(primary, l10n),
                const SizedBox(height: 14),
              ],

              if (_request.happyCode != null &&
                  _request.happyCode!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 48,
                        color: primary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.happyCode,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.shareHappyCodeNotice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: _request.happyCode!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.happyCodeCopied)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            _request.happyCode!,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 10.0,
                              color: primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.tapToCopy,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.all(16.0),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildImageSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
        fontSize: 13,
      ),
    );
  }

  Widget _buildImageGallery(List<String> urls) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: urls.map((url) {
        return GestureDetector(
          onTap: () => _openImage(url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: url,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 90,
                height: 90,
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.broken_image_rounded,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDoneChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerCard(Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.voiceNoteTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: primaryColor,
                    size: 40,
                  ),
                  onPressed: _togglePlayback,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: primaryColor,
                          inactiveTrackColor: Colors.grey.shade200,
                          thumbColor: primaryColor,
                          trackHeight: 3.0,
                        ),
                        child: Slider(
                          min: 0.0,
                          max: _playbackDuration.inMilliseconds.toDouble() > 0
                              ? _playbackDuration.inMilliseconds.toDouble()
                              : 1.0,
                          value: _playbackPosition.inMilliseconds
                              .toDouble()
                              .clamp(
                                0.0,
                                _playbackDuration.inMilliseconds.toDouble() > 0
                                    ? _playbackDuration.inMilliseconds
                                          .toDouble()
                                    : 1.0,
                              ),
                          onChanged: (val) async {
                            await _audioPlayer.seek(
                              Duration(milliseconds: val.toInt()),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_playbackPosition),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              _formatDuration(_playbackDuration),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool multiline = false,
  }) {
    return Row(
      crossAxisAlignment: multiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _technicianContactRow(String phone) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.phone_rounded, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            AppLocalizations.of(context)!.contact,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: _callTechnician,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Text(
                  phone,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.call_rounded, size: 18, color: primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
