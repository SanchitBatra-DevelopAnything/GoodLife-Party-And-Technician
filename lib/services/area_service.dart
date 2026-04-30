import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/area_model.dart';

class AreaService {
  Future<List<AreaModel>> fetchAreas() async {
    const url =
        'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/Areas.json';

    try {
      print("🚀 Calling fetchAreas");
      print("🌐 URL: $url");

      final uri = Uri.parse(url);

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      print("✅ Request completed");
      print("📡 Status Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body == 'null') return [];

        final Map<String, dynamic> data = json.decode(response.body);

        final List<AreaModel> areas = [];

        data.forEach((key, value) {
          areas.add(AreaModel.fromJson(key, value));
        });

        print("🎯 Parsed ${areas.length} areas");

        return areas;
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    }

    // 🔥 NETWORK ERRORS (most important)
    on SocketException catch (e) {
      print("❌ SocketException: $e");
      throw Exception("No Internet / DNS issue");
    }

    // 🔥 TIMEOUT (your current likely issue)
    on TimeoutException catch (e) {
      print("⏰ TimeoutException: $e");
      throw Exception("Request timed out (network issue)");
    }

    // 🔥 ANY OTHER ERROR
    catch (e) {
      print("💥 Unknown Error: $e");
      rethrow;
    }
  }
}