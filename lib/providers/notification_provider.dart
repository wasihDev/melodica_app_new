import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
import 'package:nb_utils/nb_utils.dart';

class NotificationProvider extends ChangeNotifier {
  CustomerController customerController;
  NotificationProvider({required this.customerController});
  // List<AppNotification> _notifications = [];

  // List<AppNotification> get all => _notifications;

  // List<AppNotification> get unread =>
  //     _notifications.where((e) => e.status == 'unread').toList();

  // List<AppNotification> get read =>
  //     _notifications.where((e) => e.status == 'read').toList();

  static const _readKey = 'read_notifications';

  List<AppNotification> _notifications = [];
  Set<String> _readIds = {};

  List<AppNotification> get all => _notifications;

  List<AppNotification> get unread => _notifications
      .where((e) => !_readIds.contains(e.notificationId))
      .toList();

  List<AppNotification> get read =>
      _notifications.where((e) => _readIds.contains(e.notificationId)).toList();

  /// 🔹 Load read IDs from local storage
  Future<void> _loadReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    _readIds = prefs.getStringList(_readKey)?.toSet() ?? {};
  }

  /// 🔹 Save read IDs to local storage
  Future<void> _saveReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readKey, _readIds.toList());
  }

  bool isNotificationRead(String notificationId) {
    return _readIds.contains(notificationId);
  }

  /// 🔥 REAL GET API CALL
  Future<void> fetchNotifications() async {
    try {
      await _loadReadIds();
      final uri = Uri.parse(
        "${ApiConfigService.endpoints.getNotifications}${customerController.customer!.mbId}",
      );

      final response = await http.get(
        uri,
        headers: {'api-key': "60e35fdc-401d-494d-9d78-39b15e345547"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        _notifications = data.map((e) => AppNotification.fromJson(e)).toList();

        notifyListeners();
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    _readIds.add(notificationId);
    await _saveReadIds();

    final index = _notifications.indexWhere(
      (e) => e.notificationId == notificationId,
    );

    if (index != -1) {
      _notifications[index].status = 'read';
    }

    notifyListeners();
  }
}
