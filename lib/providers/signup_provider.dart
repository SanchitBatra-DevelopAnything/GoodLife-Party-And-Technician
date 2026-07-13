import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/notification_service.dart';
import '../services/storage_service.dart';

class SignupProvider with ChangeNotifier {
  final StorageService storageService = StorageService();

  bool isLoading = false;
  double uploadProgress = 0.0;
  bool isSubmitting = false;

  Future<void> signup({
  required String username,
  required String contact,
  required String area,
  required String address,
  required File image,
  required String areaId,
}) async {
  try {
    isLoading = true;
    isSubmitting = false;
    uploadProgress = 0.0;
    notifyListeners();

    // ✅ PHASE 1: Upload
    final imageUrl = await storageService.uploadImageWithProgress(
      image,
      (progress) {
        uploadProgress = progress;
        notifyListeners();
      },
    );

    // ✅ Switch to submitting phase
    isSubmitting = true;
    notifyListeners();

    // ✅ PHASE 2: POST request
    final url = Uri.parse(
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/DistributorNotifications.json',
    );

    // ✅ Fetch real FCM token before submitting
    final fcmToken = await NotificationService().getToken() ?? '';

    final payload = {
      "distributorName": username,
      "imgUrl": imageUrl,
      "area": area,
      "address": address,
      "areaId": areaId,
      "contact": contact,
      "deviceToken": fcmToken,
      "createdAt": DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Signup failed: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  } finally {
    isLoading = false;
    isSubmitting = false;
    uploadProgress = 0.0;
    notifyListeners();
  }
}
}