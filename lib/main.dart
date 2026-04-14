import 'package:fiado_app/screen/home_page.dart';
import 'package:fiado_app/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';

import 'backup/background_worker.dart';
import 'storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  // 🔥 1. Inicializa Workmanager
  Workmanager().initialize(
    callbackDispatcher,
  );

  // 🔥 2. PEGA TOKEN CORRETAMENTE
  final token = await TokenStorage.getAccessToken();

  print('ACCESS TOKEN: $token');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caderneta',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: token == null ? LoginPage() : const HomePage(),
    );
  }
}
