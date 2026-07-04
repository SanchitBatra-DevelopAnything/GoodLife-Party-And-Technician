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

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String _progressMessage = '';
  String get progressMessage => _progressMessage;

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
      String contact = '';
      String deviceToken = '';

      if (loginContextString != null) {
        final loginContext = LoginContext.fromJson(
          jsonDecode(loginContextString),
        );
        username = loginContext.distributorDetails.distributorName;
        area = loginContext.distributorDetails.area;
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

      // 3. Upload Audio
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
        orderedBy: username,
        deviceToken: deviceToken,
        contact: contact,
        requestDate:
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
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
}
