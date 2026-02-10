import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
import 'package:melodica_app_new/views/dashboard/notification/notfication_detail_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

class LocalNotificationsService {
  // Private constructor for singleton pattern
  LocalNotificationsService._internal();

  //Singleton instance
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();

  //Factory constructor to return singleton instance
  factory LocalNotificationsService.instance() => _instance;

  //Main plugin instance for handling notifications
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  //Android-specific initialization settings using app launcher icon
  final _androidInitializationSettings = const AndroidInitializationSettings(
    '@mipmap/launcher_icon',
  );

  //iOS-specific initialization settings with permission requests
  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  //Android notification channel configuration
  final _androidChannel = const AndroidNotificationChannel(
    'channel_id',
    'Channel name',
    description: 'Android push notification channel',
    importance: Importance.max,
  );

  //Flag to track initialization status
  bool _isFlutterLocalNotificationInitialized = false;

  //Counter for generating unique notification IDs
  int _notificationIdCounter = 0;

  /// Initializes the local notifications plugin for Android and iOS.
  Future<void> init() async {
    // Check if already initialized to prevent redundant setup
    if (_isFlutterLocalNotificationInitialized) {
      return;
    }

    // Create plugin instance
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Combine platform-specific settings
    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
    );

    // Initialize plugin with settings and callback for notification taps
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap in foreground
        print('Foreground notification has been tapped1: ${response.payload}');
        print('Foreground message tap,');
        final payload = response.payload;
        // final payload = response.payload;

        if (payload != null && payload.isNotEmpty) {
          final match = RegExp(r'id:\s*([A-Z0-9-]+)').firstMatch(payload);

          if (match == null) {
            debugPrint('No ID found in payload');
            return;
          }
          // 1C7CE3E5-1CBC-4CC3-9ED0-9FA37B9300B0
          final String targetId = match.group(1)!;

          final provider = Provider.of<NotificationProvider>(
            navigatorKey.currentContext!,
            listen: false,
          );

          final notification = provider.all.firstWhere(
            (n) => n.notificationId == targetId,
            orElse: () => throw Exception('Notification not found'),
          );

          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) =>
                  NotificationDetailScreen(notification: notification),
            ),
          );
        }

        // if (payload != null && payload.isNotEmpty) {
        //   try {
        //     // 1. Convert the Map-like string to a valid JSON string
        //     // This replaces {id: with {"id": and handles the closing part
        //     String fixedPayload = payload
        //         .replaceAll('{', '{"')
        //         .replaceAll(': ', '": "')
        //         .replaceAll('}', '"}');

        //     final Map<String, dynamic> data = jsonDecode(fixedPayload);
        //     final String targetId = data['id'];

        //     final provider = Provider.of<NotificationProvider>(
        //       navigatorKey.currentContext!,
        //       listen: false,
        //     );

        //     // 2. Use find or firstWhere instead of singleWhere to prevent crashes if ID is missing
        //     final notification = provider.all.firstWhere(
        //       (n) => n.notificationId == targetId,
        //     );

        //     Navigator.push(
        //       navigatorKey.currentContext!,
        //       MaterialPageRoute(
        //         builder: (_) =>
        //             NotificationDetailScreen(notification: notification),
        //       ),
        //     );
        //   } catch (e) {
        //     print('Decoding failed. Attempting direct ID extraction...');
        //     // Fallback: If JSON is too messy, just extract the ID using Regex
        //     final match = RegExp(r'id:\s*([A-Z0-9-]+)').firstMatch(payload);
        //     if (match != null) {
        //       final String? extractedId = match.group(1);
        //       // Navigate using extractedId here...
        //     }
        //   }
        // }
        // if (response.payload == null) {
        //   print('payload null ${response.payload}');
        //   return;
        // }
        // String deepLink = jsonEncode(response.payload);
        // print('deepLink $deepLink');
        // final deepLink = jsonDecode(response.payload!)["id"].toString();

        // await GoRouter.of(context).push(deepLink);

        // final Map<String, dynamic> data = jsonDecode(response.payload!);
        // print('response.deepLink ${deepLink}');
        // final String id = data['id'];
        // print

        // print('Foreground notification has been tapped2: ${response.input}');
        // print('Foreground notification has been tapped3: ${response.data}');
        // // final Map<String, dynamic> data = jsonDecode(response.payload!);
        // print('Foreground notification has been tapped4: ${response.actionId}');
      },
    );

    // Create Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    // Mark initialization as complete
    _isFlutterLocalNotificationInitialized = true;
  }

  /// Show a local notification with the given title, body, and payload.
  Future<void> showNotification(
    String? title,
    String? body,
    String? payload,
  ) async {
    // Android-specific notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
    );

    // iOS-specific notification details
    const iosDetails = DarwinNotificationDetails();

    // Combine platform-specific details
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Display the notification
    await _flutterLocalNotificationsPlugin.show(
      _notificationIdCounter++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
