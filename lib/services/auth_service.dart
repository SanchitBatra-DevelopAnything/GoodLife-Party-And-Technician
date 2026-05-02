import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login({
    required String mobile,
    required String areaName,
  }) async {
    final response = await http.post(
      Uri.parse("YOUR_FIREBASE_FUNCTION_URL"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobile": mobile,
        "areaName": areaName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception("Login failed");
    }
  }
}