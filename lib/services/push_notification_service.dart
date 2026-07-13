import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/service_request_model.dart';

/// Queues FCM push notifications via Firebase RTDB for the admin backend to send.
class PushNotificationService {
  static const String _baseUrl =
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app';

  Future<void> notifyServiceRequestClosed(ServiceRequestModel request) async {
    final deviceToken = request.deviceToken.trim();
    if (deviceToken.isEmpty) return;

    final firebasePushId = request.firebasePushId;
    if (firebasePushId == null || firebasePushId.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ServiceRequestNotifications.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': 'service_request_closed',
          'deviceToken': deviceToken,
          'orderedBy': request.orderedBy,
          'firebasePushId': firebasePushId,
          'serviceRequestId': request.serviceRequestId,
          'title': 'Service Request Completed',
          'body':
              'Your service has been completed. Tap to view details and rate your technician if you wish.',
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        print(
          'Failed to queue service_request_closed notification: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error queuing service_request_closed notification: $e');
    }
  }
}
