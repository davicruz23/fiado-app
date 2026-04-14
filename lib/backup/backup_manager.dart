import 'package:shared_preferences/shared_preferences.dart';
import 'backup_service.dart';

class BackupManager {
  static const _key = 'last_backup';

  final BackupService service = BackupService();

  Future<void> verificarEExecutarBackup({
    required String empresaNome,
    required String userId,
    required String dbPath, // 👈 NOVO
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final lastBackup = prefs.getString(_key);
    final token = prefs.getString('accessToken');

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    if (lastBackup == null || _passouDoisDias(lastBackup)) {
      await service.enviarBackup(
        empresaNome: empresaNome,
        userId: userId,
        token: token,
        dbPath: dbPath, // 👈 ESSENCIAL
      );

      await prefs.setString(_key, DateTime.now().toIso8601String());
    }
  }

  bool _passouDoisDias(String data) {
    final last = DateTime.parse(data);
    final now = DateTime.now();

    return now.difference(last).inDays >= 2;
  }
}
