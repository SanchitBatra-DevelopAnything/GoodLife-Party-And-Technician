import 'dart:io';

import 'package:flutter/material.dart';

import '../models/service_request_model.dart';
import '../services/push_notification_service.dart';
import '../services/storage_service.dart';
import '../services/technician_service_request_service.dart';

class TechnicianServiceRequestProvider extends ChangeNotifier {
  final TechnicianServiceRequestService _service =
      TechnicianServiceRequestService();
  final StorageService _storageService = StorageService();
  final PushNotificationService _pushNotificationService =
      PushNotificationService();

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _fetchError;
  String? get fetchError => _fetchError;

  String _progressMessage = '';
  String get progressMessage => _progressMessage;

  List<ServiceRequestModel> _assignedRequests = [];
  List<ServiceRequestModel> get assignedRequests => _assignedRequests;

  List<ServiceRequestModel> get activeRequests =>
      _assignedRequests.where((r) => r.isActive).toList();

  List<ServiceRequestModel> get completedRequests =>
      _assignedRequests.where((r) => r.isCompleted).take(10).toList();

  Future<void> fetchAssignedRequests(String technicianId) async {
    if (technicianId.isEmpty) return;

    try {
      _isFetching = true;
      _fetchError = null;
      notifyListeners();

      _assignedRequests =
          await _service.fetchAssignedRequests(technicianId);
    } catch (e) {
      _fetchError = 'Failed to load service requests. Please try again.';
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  ServiceRequestModel? getRequestById(String id) {
    try {
      return _assignedRequests.firstWhere(
        (r) => r.serviceRequestId == id,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> uploadImage(File file) async {
    return _storageService.uploadServiceRequestMedia(
      file: file,
      fileType: 'image',
      extension: 'jpg',
      onProgress: (_) {},
    );
  }

  Future<ServiceRequestModel> saveWorkUpdate(
    ServiceRequestModel request,
  ) async {
    try {
      _isSaving = true;
      notifyListeners();

      var toSave = request;
      final status = request.status.toUpperCase();
      if (status == 'TECHNICIAN_ASSIGNED' ||
          status == 'APPROVED' ||
          status == 'PENDING') {
        toSave = request.copyWith(status: 'IN_PROGRESS');
      }

      final previousStatus = _assignedRequests
              .where((r) => r.serviceRequestId == toSave.serviceRequestId)
              .map((r) => r.status.toUpperCase())
              .firstOrNull ??
          '';

      final updated = await _service.updateRequest(toSave);
      final index = _assignedRequests.indexWhere(
        (r) => r.serviceRequestId == updated.serviceRequestId,
      );
      if (index >= 0) {
        _assignedRequests[index] = updated;
      }

      if (updated.status.toUpperCase() == 'CLOSED' &&
          previousStatus != 'CLOSED') {
        await _pushNotificationService.notifyServiceRequestClosed(updated);
      }

      notifyListeners();
      return updated;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> validateHappyCodeOnly({
    required ServiceRequestModel request,
    required String happyCode,
  }) {
    return _service.validateHappyCode(
      request: request,
      enteredCode: happyCode,
    );
  }

  Future<bool> validateAndCloseTicket({
    required ServiceRequestModel request,
    required String happyCode,
    required String paymentMode,
    required double paymentAmount,
  }) async {
    final isValid = await _service.validateHappyCode(
      request: request,
      enteredCode: happyCode,
    );

    if (!isValid) return false;

    final closed = request.copyWith(
      status: 'CLOSED',
      paymentMode: paymentMode,
      paymentAmount: paymentAmount,
    );

    await saveWorkUpdate(closed);
    return true;
  }
}
