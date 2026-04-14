import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/environment.dart';

class BackupService {
  final String baseUrl = Environment.apiBaseUrl;

  Future<void> enviarBackup({
    required String empresaNome,
    required String userId,
    required String token,
    required String dbPath, // 👈 caminho do arquivo no celular
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/backup/sqlite'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['empresaNome'] = empresaNome;
    request.fields['userId'] = userId;

    request.files.add(await http.MultipartFile.fromPath('file', dbPath));

    var response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      print('STATUS: ${response.statusCode}');
      print('BODY: $responseBody');
      throw Exception('Erro ao enviar backup');
    }

    final data = jsonDecode(responseBody);
    print('Backup criado: ${data['fileName']}');
  }
}
