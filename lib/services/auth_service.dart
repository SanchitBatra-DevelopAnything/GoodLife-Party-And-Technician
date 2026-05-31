import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/login_context.dart';

class AuthService {
  Future<LoginContext> login({
    required String mobile,
    required String areaName,
  }) async {
    final response = await http.post(
      Uri.parse(
        "https://loginparty-kind2bfhcq-as.a.run.app",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "mobile": mobile,
        "areaName": areaName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return LoginContext.fromJson(data);
    }

    throw Exception("Login failed");
  }
}