import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<String?> getDeviceToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 1. Request Permission (Required for iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // 2. iOS Specific: Wait for APNS token to be ready
    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      debugPrint("apnsToken Token: $apnsToken");
      if (apnsToken == null) {
        // If it's null, we wait a bit or the getToken() might fail
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // 3. Get the actual FCM Token (Works for both platforms)
    String? fcmToken = await messaging.getToken();
    debugPrint("FCM Token: $fcmToken");
    return fcmToken;
  } else {
    debugPrint('User declined or has not accepted permission');
    return null;
  }
}
