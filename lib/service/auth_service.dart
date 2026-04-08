import 'dart:convert';
import 'package:fiado_app/storage/session.dart';
import 'package:http/http.dart' as http;
import 'package:fiado_app/models/dto/login_response.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cpf': cpf, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final loginResponse = LoginResponse.fromJson(data);

      Map<String, dynamic> decodedToken = JwtDecoder.decode(
        loginResponse.accessToken,
      );

      Session.nome = decodedToken['nome'];

      print('Nome do usuário: $Session.nome');

      return loginResponse;
    } else {
      return null;
    }
  }
}
