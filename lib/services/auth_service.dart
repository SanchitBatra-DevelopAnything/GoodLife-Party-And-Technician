import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/login_context.dart';
import '../utils/session_status.dart';

class AuthService {
  Future<LoginContext> login({
    required String mobile,
    required String areaName,
  }) async {
    final response = await http.post(
      Uri.parse(
        "https://loginparty-kind2bfhcq-as.a.run.app",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "mobile": mobile,
        "areaName": areaName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print("Received login response: $data");

      return LoginContext.fromJson(data);
    }

    throw Exception("Login failed");
  }

  Future<SessionStatus> validateUserSession({
    required String mobile,
    required String areaName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://loginparty-kind2bfhcq-as.a.run.app",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "mobile": mobile,
          "areaName": areaName,
        }),
      );

      if (response.statusCode == 200) {
        return SessionStatus.valid;
      }

      return SessionStatus.invalid;
    } catch (_) {
      return SessionStatus.inconclusive;
    }
  }

  Future<void> updateDeviceToken(String mobile, String token) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://asia-southeast1-goodlifeadminapp.cloudfunctions.net/updateDeviceToken',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': mobile,
          'deviceToken': token,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Device token updated successfully.');
      } else {
        print('❌ Failed to update device token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating device token: $e');
    }
  }
}