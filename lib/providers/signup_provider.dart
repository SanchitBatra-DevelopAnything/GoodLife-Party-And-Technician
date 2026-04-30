import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/storage_service.dart';

class SignupProvider with ChangeNotifier {
  final StorageService storageService = StorageService();

  bool isLoading = false;
  double uploadProgress = 0.0;

  Future<void> signup({
    required String username,
    required String contact,
    required String area,
    required File image,
  }) async {
    try {
      isLoading = true;
      uploadProgress = 0.0;
      notifyListeners();

      // ✅ 1. Upload image
      final imageUrl = await storageService.uploadImageWithProgress(
        image,
        (progress) {
          uploadProgress = progress;
          notifyListeners();
        },
      );

      // ✅ 2. Send POST request directly
      final url = Uri.parse(
        'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/DistributorNotifications.json',
      );

      final payload = {
        "distributorName": username,
        "imgUrl": imageUrl,
        "area": area,
        "contact": contact,
        "deviceToken": "random_token_123",
        "createdAt": DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception('Signup failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      uploadProgress = 0.0;
      notifyListeners();
    }
  }
}