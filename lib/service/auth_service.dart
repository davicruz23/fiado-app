import 'dart:convert';
import 'package:fiado_app/storage/session.dart';
import 'package:http/http.dart' as http;
import 'package:fiado_app/models/dto/login_response.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backup/background_worker.dart';
import '../env/environment.dart';
import '../database/database_helper.dart';
import '../storage/token_storage.dart';

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

    // USUÁRIO INATIVO
    if (response.statusCode == 403) {
      final data = jsonDecode(response.body);
      throw Exception(
        data['message'] ?? 'Usuário inativo entrar em contato com suporte.',
      );
    }

    // OUTROS ERROS
    if (response.statusCode != 200) {
      throw Exception('Erro ao fazer login. Código: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final loginResponse = LoginResponse.fromJson(data);

    await TokenStorage.saveTokens(
      loginResponse.accessToken,
      loginResponse.refreshToken,
    );

    Map<String, dynamic> decodedToken = JwtDecoder.decode(
      loginResponse.accessToken,
    );

    final empresaNome = decodedToken['nome'] ?? 'empresa';
    final userId = decodedToken['sub'] ?? '0';

    Session.nome = empresaNome;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('empresa_nome', empresaNome);
    await prefs.setString('user_id', userId);

    final db = await DatabaseHelper.instance.database;
    await db.rawQuery('SELECT 1');

    await Workmanager().cancelByUniqueName("backupTaskUnique");

    await Workmanager().registerPeriodicTask(
      "testeBackup",
      backupTask,
      frequency: const Duration(hours: 24),
    );

    return loginResponse;
  }
}
