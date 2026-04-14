import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../env/environment.dart';
import '../database/database_helper.dart';
import '../storage/token_storage.dart';

const String backupTask = "backupTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("🚀 WORKER DISPARADO: $task");

    if (task == backupTask) {
      try {
        final token = await TokenStorage.getAccessToken();

        if (token == null) {
          print("❌ Sem token");
          return Future.value(true);
        }

        final dbPath = await DatabaseHelper.instance.getDatabasePath();

        final prefs = await SharedPreferences.getInstance();
        final empresaNome = prefs.getString('empresa_nome') ?? 'empresa';
        final userId = prefs.getString('user_id') ?? '0';

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${Environment.apiBaseUrl}/backup/sqlite'),
        );

        request.headers['Authorization'] = 'Bearer $token';

        request.fields['empresaNome'] = empresaNome;
        request.fields['userId'] = userId;

        request.files.add(await http.MultipartFile.fromPath('file', dbPath));

        var response = await request.send();

        if (response.statusCode == 200) {
          print("✅ BACKUP OK");
        } else {
          print("❌ ERRO BACKUP");
        }
      } catch (e) {
        print("🔥 ERRO: $e");
      }
    }

    return Future.value(true);
  });
}
