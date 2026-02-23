import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/global_variables.dart';
import 'package:melodica_app_new/firebase_options.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/views/dashboard/notification/notfication_detail_screen.dart';
import 'package:melodica_app_new/views/dashboard/notification/services/local_notifications_service.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

class FirebaseMessagingService {
  // Private constructor for singleton pattern
  FirebaseMessagingService._internal();

  // Singleton instance
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  // Factory constructor to provide singleton instance
  factory FirebaseMessagingService.instance() => _instance;

  // Reference to local notifications service for displaying notifications
  LocalNotificationsService? _localNotificationsService;

  /// Initialize Firebase Messaging and sets up all message listeners
  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    // Init local notifications service
    _localNotificationsService = localNotificationsService;

    // Handle FCM token
    _handlePushNotificationsToken();

    // Request user permission for notifications
    _requestPermission();

    // Register handler for background messages (app terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen for messages when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Retrieves and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken() async {
    // Get the FCM token for the device
    // final token = await FirebaseMessaging.instance.getToken();
    // print('Push notifications token: $token');
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        // If it's null, we wait a bit or the getToken() might fail
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // 3. Get the actual FCM Token (Works for both platforms)
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("Push notifications token: $fcmToken");
    // Listen for token refresh events
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) {
          print('FCM token refreshed: $fcmToken');
          // TODO: optionally send token to your server for targeting this device
        })
        .onError((error) {
          // Handle errors during token refresh
          print('Error refreshing FCM token: $error');
        });
  }

  /// Requests notification permission from the user
  Future<void> _requestPermission() async {
    // Request permission for alerts, badges, and sounds
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Log the user's permission decision
    print('User granted permission: ${result.authorizationStatus}');
  }

  /// Handles messages received while the app is in the foreground
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.data.toString()}');

    final notificationData = message.notification;
    if (notificationData != null) {
      // Display a local notification using the service
      _localNotificationsService?.showNotification(
        notificationData.title,
        notificationData.body,
        message.data.toString(),
      );
    }
    await Future.delayed(const Duration(milliseconds: 500));

    final context = navigatorKey.currentContext;
    if (context == null) return;

    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final ctrl = Provider.of<CustomerController>(context, listen: false);
    print('provider.all.isEmpty ${provider.all.isEmpty}');
    // Ensure data is loaded
    await ctrl.fetchCustomerData();
    await provider.fetchNotifications();
    // call notificaiton here
  }

  /// Handles notification taps when app is opened from the background or terminated state
  void _onMessageOpenedApp(RemoteMessage message) {
    print('Notification caused the app to open: ${message.data.toString()}');
    // TODO: Add navigation or specific handling based on message data
    _handleInitialNavigation(message);
    // F2F6C84E-A496-4E57-A8CC-2E06B491A754
    // 1C7CE3E5-1CBC-4CC3-9ED0-9FA37B9300B0
    // Navigator.push(context, route)
  }

  void _handleInitialNavigation(RemoteMessage message) async {
    final notificationId = message.data['id'];
    if (notificationId == null) return;
    openedFromNotification = true; // 🔴 Important

    // Wait until app + providers are ready
    await Future.delayed(const Duration(seconds: 1));

    final context = navigatorKey.currentContext;
    if (context == null) return;

    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final ctrl = Provider.of<CustomerController>(context, listen: false);
    print('provider.all.isEmpty ${provider.all.isEmpty}');
    // Ensure data is loaded
    await ctrl.fetchCustomerData();
    await provider.fetchNotifications();

    final notification = provider.all.firstWhere(
      (n) => n.notificationId == notificationId,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(notification: notification),
      ),
    );
  }
}

/// Background message handler (must be top-level function or static)
/// Handles messages when the app is fully terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('Background message received: ${message.data}');

  // Example: Show a local notification
  // await LocalNotificationsService.showNotification(
  //   message.data['title'] ?? 'New Notification',
  //   message.data['body'] ?? '',
  //   message.data['id'], // optional
  // );
  final localNotificationService = LocalNotificationsService.instance();
  await localNotificationService.showNotification(
    message.data['title'] ?? 'New Notification',
    message.data['body'] ?? '',
    message.data['id'],
  );

  // final cusprovider = Provider.of<CustomerController>(
  //   navigatorKey.currentContext!,
  //   listen: false,
  // );
  // await cusprovider.fetchCustomerData();
  // navigatorKey.currentContext!
  //     .read<NotificationProvider>()
  //     .fetchNotifications();

  print('Background message received: ${message.data.toString()}');
}
