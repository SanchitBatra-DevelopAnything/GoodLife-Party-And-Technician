import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_request_model.dart';

class ServiceRequestService {
  Future<void> placeServiceRequest(ServiceRequestModel request) async {
    final url =
        'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/serviceRequests/${request.orderedBy}.json';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to place service request');
    }
  }
}
