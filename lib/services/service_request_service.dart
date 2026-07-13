import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/service_request_model.dart';

class ServiceRequestService {
  static const String _baseUrl =
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app';

  String _generateHappyCode() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<void> placeServiceRequest(ServiceRequestModel request) async {
    final url = '$_baseUrl/serviceRequests/${request.orderedBy}.json';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(
        // Generate happy code before saving
        request.copyWith(happyCode: _generateHappyCode()).toJson(),
      ),
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
          final data = Map<String, dynamic>.from(entry.value);
          data['firebasePushId'] = entry.key;
          requests.add(ServiceRequestModel.fromJson(data));
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

    // Return only the most recent 10, matching order history behaviour
    return requests.take(10).toList();
  }

  /// Fetches a single service request by party name and Firebase push key.
  Future<ServiceRequestModel?> fetchServiceRequestByKey({
    required String orderedBy,
    required String firebasePushId,
  }) async {
    final url = '$_baseUrl/serviceRequests/$orderedBy/$firebasePushId.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final body = jsonDecode(response.body);
    if (body == null || body is! Map<String, dynamic>) {
      return null;
    }

    final data = Map<String, dynamic>.from(body);
    data['firebasePushId'] = firebasePushId;
    if ((data['orderedBy'] ?? '').toString().isEmpty) {
      data['orderedBy'] = orderedBy;
    }

    return ServiceRequestModel.fromJson(data);
  }

  Future<ServiceRequestModel> submitTechnicianRating({
    required ServiceRequestModel request,
    required int rating,
    String? comment,
  }) async {
    if (request.firebasePushId == null || request.orderedBy.isEmpty) {
      throw Exception('Missing Firebase reference for this request');
    }
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }
    if (!request.canRateTechnician) {
      throw Exception('This request cannot be rated');
    }

    final url =
        '$_baseUrl/serviceRequests/${request.orderedBy}/${request.firebasePushId}.json';

    final payload = <String, dynamic>{
      'technicianRating': rating,
      'technicianRatingAt': DateTime.now().toIso8601String(),
    };

    final trimmedComment = comment?.trim();
    if (trimmedComment != null && trimmedComment.isNotEmpty) {
      payload['technicianRatingComment'] = trimmedComment;
    }

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to submit rating');
    }

    return request.copyWith(
      technicianRating: rating,
      technicianRatingComment: trimmedComment,
      technicianRatingAt: payload['technicianRatingAt'] as String,
    );
  }
}
