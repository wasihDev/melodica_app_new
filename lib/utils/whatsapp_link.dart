import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsApp(String productNames) async {
  final phone = '97145591000';

  final message =
      'Hello, I have just purchased $productNames through the app, Kindly assist me in scheduling it.';

  final encodedMessage = Uri.encodeComponent(message);

  final url = Uri.parse(
    'https://api.whatsapp.com/send/?phone=$phone&text=$encodedMessage',
  );

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch WhatsApp';
  }
}
