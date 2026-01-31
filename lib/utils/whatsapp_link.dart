import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsApp(String productNames) async {
  final phone = '97145591000';

  final message =
      'Hello, I have just purchased $productNames through the app, Kindly assist me in scheduling it.';

  final encodedMessage = Uri.encodeComponent(message);

  Uri url;
  if (Platform.isAndroid) {
    url = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMessage');
  } else {
    // Web or unsupported platform
    url = Uri.parse(
      'https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage',
    );
  }
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('Could not launch WhatsApp. Make sure the app is installed.');
    // O
  }
}
