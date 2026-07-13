import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/service_request_model.dart';

class TechnicianServiceRequestService {
  static const String _baseUrl =
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app';

  Future<Map<String, String>> _fetchDistributorAddresses() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/Distributors.json'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return {};
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) return {};

    final addresses = <String, String>{};
    for (final entry in body.entries) {
      try {
        final data = Map<String, dynamic>.from(entry.value as Map);
        final name =
            (data['distributorName'] ?? data['name'] ?? entry.key).toString();
        final address = data['address']?.toString().trim() ?? '';
        if (name.isNotEmpty && address.isNotEmpty) {
          addresses[name] = address;
        }
      } catch (_) {
        // Skip malformed entries
      }
    }
    return addresses;
  }

  Future<List<ServiceRequestModel>> fetchAssignedRequests(
    String technicianId,
  ) async {
    final results = await Future.wait([
      http.get(Uri.parse('$_baseUrl/serviceRequests.json')),
      _fetchDistributorAddresses(),
    ]);

    final response = results[0] as http.Response;
    final distributorAddresses = results[1] as Map<String, String>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch service requests');
    }

    final body = jsonDecode(response.body);
    if (body == null) return [];

    final List<ServiceRequestModel> requests = [];

    if (body is Map<String, dynamic>) {
      for (final partyEntry in body.entries) {
        final partyName = partyEntry.key;
        final partyRequests = partyEntry.value;
        if (partyRequests is! Map) continue;

        for (final pushEntry in partyRequests.entries) {
          try {
            final data = Map<String, dynamic>.from(pushEntry.value as Map);
            final assignedId = data['assignedTechnicianId']?.toString();
            if (assignedId != technicianId) continue;

            data['firebasePushId'] = pushEntry.key;
            if ((data['orderedBy'] ?? '').toString().isEmpty) {
              data['orderedBy'] = partyName;
            }
            if ((data['serviceRequestId'] ?? '').toString().isEmpty) {
              data['serviceRequestId'] = pushEntry.key;
            }

            final orderedBy = data['orderedBy'].toString();
            final requestAddress = data['address']?.toString().trim() ?? '';
            if (requestAddress.isEmpty) {
              final distributorAddress = distributorAddresses[orderedBy];
              if (distributorAddress != null && distributorAddress.isNotEmpty) {
                data['address'] = distributorAddress;
              }
            }

            requests.add(ServiceRequestModel.fromJson(data));
          } catch (_) {
            // Skip malformed entries
          }
        }
      }
    }

    requests.sort((a, b) {
      final dateCompare = b.requestDate.compareTo(a.requestDate);
      if (dateCompare != 0) return dateCompare;
      return b.requestTime.compareTo(a.requestTime);
    });

    return requests;
  }

  Future<ServiceRequestModel> updateRequest(
    ServiceRequestModel request,
  ) async {
    if (request.firebasePushId == null || request.orderedBy.isEmpty) {
      throw Exception('Missing Firebase reference for this request');
    }

    final url =
        '$_baseUrl/serviceRequests/${request.orderedBy}/${request.firebasePushId}.json';

    final payload = request.toJson()
      ..remove('firebasePushId');

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update service request');
    }

    return request;
  }

  Future<bool> validateHappyCode({
    required ServiceRequestModel request,
    required String enteredCode,
  }) async {
    return request.happyCode != null &&
        request.happyCode!.trim() == enteredCode.trim();
  }

  Future<void> syncPayment({
    required ServiceRequestModel request,
    required String paymentMode,
    required double amount,
  }) async {
    await updateRequest(
      request.copyWith(
        paymentMode: paymentMode,
        paymentAmount: amount,
      ),
    );
  }
}
