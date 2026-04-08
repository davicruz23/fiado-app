import 'package:url_launcher/url_launcher.dart';

Future<void> sendWhatsApp(String phone, String message) async {
  final url = Uri.parse(
    'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
  );

  await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  );
}