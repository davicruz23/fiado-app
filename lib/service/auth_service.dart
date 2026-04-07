import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fiado_app/models/dto/login_response.dart';

import '../env/environment.dart';

class LoginException implements Exception {
  final String message;
  LoginException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final String baseUrl = Environment.apiBaseUrl;

  Future<LoginResponse?> login(String cpf, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cpf': cpf,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LoginResponse.fromJson(data);
    } else {
      return null;
    }
  }
}