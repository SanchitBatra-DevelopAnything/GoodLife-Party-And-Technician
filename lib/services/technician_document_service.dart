import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
class TechnicianDocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveDocumentMetadata({
    required String partyId,
    required String fileName,
    required String url,
    required String storagePath,
    required String type,
  }) async {
    final rtdbUrl =
        'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/partyDocuments/$partyId.json';

    final response = await http.post(
      Uri.parse(rtdbUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fileName': fileName,
        'url': url,
        'storagePath': storagePath,
        'type': type,
        'uploadedAt': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode >= 300) {
      throw Exception('Failed to save document metadata: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchParties() async {
    try {
      // First try to fetch from RTDB Distributors
      final url = 'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/Distributors.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body != null && body is Map<String, dynamic>) {
          final List<Map<String, dynamic>> parties = [];
          for (final entry in body.entries) {
            try {
              final data = Map<String, dynamic>.from(entry.value);
              data['id'] = entry.key; // The push ID or distributor name
              // Use the name from the data or fallback to the key
              data['distributorName'] = data['distributorName'] ?? data['name'] ?? entry.key;
              parties.add(data);
            } catch (_) {}
          }
          if (parties.isNotEmpty) return parties;
        }
      }

      // Fallback: Check Firestore Distributors collection
      final snapshot = await _firestore.collection('Distributors').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['distributorName'] = data['distributorName'] ?? data['name'] ?? doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching parties: $e');
      return [];
    }
  }
}
