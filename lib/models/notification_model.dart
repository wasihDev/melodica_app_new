import 'dart:convert';

class AppNotification {
  final String notificationId;
  final String title;
  final String messageText;
  final String messageRich;
  final String category;
  final String type;
  final String layout;
  final int priority;
  String status;
  final String? imageUrl;
  final String? iconUrl;
  final List<NotificationAction> actions;
  // 🔹 NEW
  final DateTime? validFrom;
  final DateTime? validTo;
  AppNotification({
    required this.notificationId,
    required this.title,
    required this.messageText,
    required this.messageRich,
    required this.category,
    required this.type,
    required this.layout,
    required this.priority,
    required this.status,
    this.imageUrl,
    this.iconUrl,
    required this.actions,
    this.validFrom,
    this.validTo,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // print('NotificationAction json ${json} ');
    return AppNotification(
      // Use the ?? operator to provide a fallback if the API returns null
      notificationId: json['NotificationId']?.toString() ?? '',
      title: json['Title'] ?? 'No Title',
      messageText: json['MessageText'] ?? '',
      messageRich: json['MessageRich'] ?? '', // This is often null
      category: json['Category'] ?? 'default',
      type: json['Type'] ?? 'general',
      layout: json['Layout'] ?? 'basic',
      priority: json['Priority'] ?? 0,
      status: json['Status'] ?? 'unread',
      imageUrl: json['ImageUrl'],
      iconUrl: json['IconUrl'],
      actions:
          (json['Actions'] as List?)
              ?.map((e) => NotificationAction.fromJson(e))
              .toList() ??
          [], // Handle case where Actions list itself is null
      validFrom: json['ValidFromUtc'] != null
          ? DateTime.parse(json['ValidFromUtc'])
          : null,
      validTo: json['ValidToUtc'] != null
          ? DateTime.parse(json['ValidToUtc'])
          : null,
    );
  }

  bool get isRead => status == 'read';
}

class NotificationAction {
  final int id;
  final int order;
  final String label;
  final String actionType;
  final String? route;
  final String? url;
  final Map<String, dynamic>? routeParams;
  final bool dismissOnTap;

  // /// ⏳ Expiry fields (STRING from API)
  // final String? validFrom; // yyyy-MM-dd
  // final String? validTo; // yyyy-MM-dd

  NotificationAction({
    required this.id,
    required this.order,
    required this.label,
    required this.actionType,
    this.route,
    this.url,
    this.routeParams,
    required this.dismissOnTap,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['NotificationActionId'],
      order: json['Order'],
      label: json['Label'],
      actionType: json['ActionType'],
      route: json['Route'],
      url: json['Url'],
      routeParams: json['RouteParamsJson'] != null
          ? jsonDecode(json['RouteParamsJson'])
          : null,
      dismissOnTap: json['DismissOnTap'] ?? false,

      // validFrom: json['valid_from'],
      // validTo: json['valid_to'],
      // 🔹 NEW
    );
  }

  /// ✅ Action availability logic for STRING
  ///
  // bool get isActive {
  //   if (validFrom == null && validTo == null) return true;

  //   final now = DateTime.now();

  //   final from = validFrom != null ? DateTime.tryParse(validFrom!) : null;

  //   final to = validTo != null ? DateTime.tryParse(validTo!) : null;

  //   if (from != null && now.isBefore(from)) return false;
  //   if (to != null && now.isAfter(to)) return false;

  //   return true;
  // }
}

extension NotificationActionX on AppNotification {
  bool get isValidNow {
    final now = DateTime.now();

    if (validFrom != null && now.isBefore(validFrom!)) {
      print('❌ Failed: Current time $now is BEFORE $validFrom');
      return false;
    }

    if (validTo != null && now.isAfter(validTo!)) {
      print('❌ Failed: Current time $now is AFTER $validTo');
      return false;
    }

    print('✅ Valid: $now is within range');
    return true;
  }
}
  // extension NotificationActionX on AppNotification {
  //   bool get isValidNow {
  //     final now = DateTime.now();
  //     print('validFrom $validFrom');
  //     print('validTo $validTo');
  //     if (validFrom != null && now.isBefore(validFrom!)) {
  //       return false;
  //     }

  //     if (validTo != null && now.isAfter(validTo!)) {
  //       return false;
  //     }

  //     return true;
  //   }
// }
