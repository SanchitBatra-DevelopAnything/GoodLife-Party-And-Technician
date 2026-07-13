import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/technician_login_context.dart';
import '../models/technician_model.dart';
import '../utils/session_status.dart';

class TechnicianAuthService {
  static const String _baseUrl =
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app';

  Future<TechnicianLoginContext> login({
    required String mobile,
    required String password,
  }) async {
    if (mobile.length != 10) {
      throw Exception('Invalid mobile number');
    }
    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    final response = await http.get(Uri.parse('$_baseUrl/Technicians.json'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to connect to server');
    }

    final body = jsonDecode(response.body);
    if (body == null || body is! Map<String, dynamic>) {
      throw Exception('Invalid credentials');
    }

    for (final entry in body.entries) {
      final data = Map<String, dynamic>.from(entry.value as Map);
      final techMobile = (data['mobile'] ?? '').toString();
      if (techMobile != mobile) continue;

      final storedPassword = (data['password'] ?? '').toString();
      if (storedPassword != password) {
        throw Exception('Invalid password');
      }

      return TechnicianLoginContext(
        technician: TechnicianModel(
          technicianId: entry.key,
          name: data['name']?.toString() ?? 'Technician',
          phone: techMobile,
          photoUrl: data['photoUrl']?.toString(),
          area: data['area']?.toString() ?? '',
        ),
      );
    }

    throw Exception('Technician not found');
  }

  Future<SessionStatus> validateTechnicianSession({
    required String technicianId,
  }) async {
    if (technicianId.isEmpty) {
      return SessionStatus.invalid;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Technicians/$technicianId.json'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return SessionStatus.inconclusive;
      }

      final body = jsonDecode(response.body);
      if (body == null) {
        return SessionStatus.invalid;
      }

      return SessionStatus.valid;
    } catch (_) {
      return SessionStatus.inconclusive;
    }
  }

  Future<void> updateDeviceToken({
    required String technicianId,
    required String token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/Technicians/$technicianId.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceToken': token}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Technician device token updated successfully.');
      } else {
        print(
          '❌ Failed to update technician device token: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error updating technician device token: $e');
    }
  }

  Future<String?> fetchTechnicianPhoneById(String technicianId) async {
    if (technicianId.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Technicians/$technicianId.json'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final body = jsonDecode(response.body);
      if (body == null || body is! Map) return null;

      final phone = (body['mobile'] ?? body['phone'] ?? '').toString();
      return phone.isNotEmpty ? phone : null;
    } catch (_) {
      return null;
    }
  }
}
