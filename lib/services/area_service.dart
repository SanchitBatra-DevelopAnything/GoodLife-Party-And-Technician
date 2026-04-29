import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/area_model.dart';

class AreaService {
  Future<List<AreaModel>> fetchAreas() async {
    print("Calling fetchAreas");
    final response = await http.get(
      Uri.parse(
        'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/Areas.json',
      ),
    );

    print("Completed the request");

    if (response.statusCode == 200) {
      if (response.body == 'null') return [];
      print("Received areas data: ${response.body}");

      final Map<String, dynamic> data = json.decode(response.body);

      final List<AreaModel> areas = [];

      data.forEach((key, value) {
        areas.add(AreaModel.fromJson(key, value));
      });

      return areas;
    } else {
      print('Failed to load areas: ${response.body}');
      throw Exception('Failed to load areas');
    }
  }
}