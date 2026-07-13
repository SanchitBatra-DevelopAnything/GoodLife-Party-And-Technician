import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/login_context.dart';
import '../models/service_request_model.dart';
import '../services/service_request_service.dart';
import '../services/storage_service.dart';

class ServiceRequestProvider with ChangeNotifier {
  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  final StorageService _storageService = StorageService();

  // ── Submit state ──────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String _progressMessage = '';
  String get progressMessage => _progressMessage;

  // ── Fetch state ───────────────────────────────────────────────────────────
  bool _isFetching = false;
  bool get isFetching => _isFetching;

  String? _fetchError;
  String? get fetchError => _fetchError;

  List<ServiceRequestModel> _serviceRequests = [];
  List<ServiceRequestModel> get serviceRequests => _serviceRequests;

  /// Fetch all service requests for the logged-in party.
  Future<void> fetchServiceRequests(String partyName) async {
    if (partyName.isEmpty) return;

    try {
      _isFetching = true;
      _fetchError = null;
      notifyListeners();

      _serviceRequests =
          await _serviceRequestService.fetchServiceRequests(partyName);
    } catch (e) {
      _fetchError = 'Failed to load service requests. Please try again.';
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> submitServiceRequest({
    required List<String> machineIds,
    required List<String> machineNames,
    required List<File> images,
    required File? audio,
    required String type, // 'SERVICE' or 'INSTALLATION'
    required String description,
  }) async {
    try {
      _isSubmitting = true;
      _progressMessage = 'Preparing request...';
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final loginContextString = prefs.getString('login_context');

      String username = 'UNKNOWN_USER';
      String area = '';
      String address = '';
      String contact = '';
      String deviceToken = '';

      if (loginContextString != null) {
        final loginContext = LoginContext.fromJson(
          jsonDecode(loginContextString),
        );
        username = loginContext.distributorDetails.distributorName;
        area = loginContext.distributorDetails.area;
        address = loginContext.distributorDetails.address;
        contact = loginContext.distributorDetails.contact;
        deviceToken = loginContext.distributorDetails.deviceToken;
      }

      final List<String> imageUrls = [];
      String? audioUrl;

      // 1. Upload Images
      for (int i = 0; i < images.length; i++) {
        _progressMessage = 'Uploading image ${i + 1} of ${images.length}...';
        notifyListeners();
        final imageUrl = await _storageService.uploadServiceRequestMedia(
          file: images[i],
          fileType: 'image',
          extension: 'jpg',
          onProgress: (progress) {},
        );
        imageUrls.add(imageUrl);
      }

      // 2. Upload Audio
      if (audio != null) {
        _progressMessage = 'Uploading audio...';
        notifyListeners();
        final ext = audio.path.split('.').last;
        audioUrl = await _storageService.uploadServiceRequestMedia(
          file: audio,
          fileType: 'audio',
          extension: ext,
          onProgress: (progress) {},
        );
      }

      _progressMessage = 'Creating service request...';
      notifyListeners();

      final now = DateTime.now();
      final request = ServiceRequestModel(
        serviceRequestId: const Uuid().v4(),
        machineIds: machineIds,
        machineNames: machineNames,
        area: area,
        address: address.isNotEmpty ? address : null,
        orderedBy: username,
        deviceToken: deviceToken,
        contact: contact,
        requestDate:
            "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}",
        requestTime:
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
        type: type,
        description: description,
        imageUrls: imageUrls,
        audioUrl: audioUrl,
        status: 'PENDING',
      );

      await _serviceRequestService.placeServiceRequest(request);

      _progressMessage = 'Request submitted successfully';
      notifyListeners();
    } catch (e) {
      _progressMessage = 'Failed to submit request';
      notifyListeners();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<ServiceRequestModel> submitTechnicianRating({
    required ServiceRequestModel request,
    required int rating,
    String? comment,
  }) async {
    try {
      _isFetching = true;
      _fetchError = null;
      notifyListeners();

      final updated = await _serviceRequestService.submitTechnicianRating(
        request: request,
        rating: rating,
        comment: comment,
      );

      final index = _serviceRequests.indexWhere(
        (r) => r.serviceRequestId == updated.serviceRequestId,
      );
      if (index >= 0) {
        _serviceRequests[index] = updated;
      }

      notifyListeners();
      return updated;
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
