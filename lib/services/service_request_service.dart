import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_request_model.dart';

class ServiceRequestService {
  static const String _baseUrl =
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app';

  Future<void> placeServiceRequest(ServiceRequestModel request) async {
    final url = '$_baseUrl/serviceRequests/${request.orderedBy}.json';

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

  /// Fetches all service requests for a given party (by their distributorName).
  Future<List<ServiceRequestModel>> fetchServiceRequests(
      String partyName) async {
    final url = '$_baseUrl/serviceRequests/$partyName.json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch service requests');
    }

    final body = jsonDecode(response.body);

    // Firebase returns null when no data exists at the node
    if (body == null) return [];

    final List<ServiceRequestModel> requests = [];

    // Firebase stores pushed items as a Map<String, dynamic> with auto-generated keys
    if (body is Map<String, dynamic>) {
      for (final entry in body.entries) {
        try {
          requests.add(ServiceRequestModel.fromJson(
            Map<String, dynamic>.from(entry.value),
          ));
        } catch (_) {
          // Skip malformed entries
        }
      }
    }

    // Sort newest first by date then time
    requests.sort((a, b) {
      final dateCompare = b.requestDate.compareTo(a.requestDate);
      if (dateCompare != 0) return dateCompare;
      return b.requestTime.compareTo(a.requestTime);
    });

    return requests;
  }
}
