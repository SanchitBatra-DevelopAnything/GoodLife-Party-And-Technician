import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/area_model.dart';

class AreaService {
  Future<List<AreaModel>> fetchAreas() async {
    final response = await http.get(
      Uri.parse(
        'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/Areas.json',
      ),
    );

    if (response.statusCode == 200) {
      if (response.body == 'null') return [];

      final Map<String, dynamic> data = json.decode(response.body);

      final List<AreaModel> areas = [];

      data.forEach((key, value) {
        areas.add(AreaModel.fromJson(key, value));
      });

      return areas;
    } else {
      throw Exception('Failed to load areas');
    }
  }
}