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
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['NotificationId'],
      title: json['Title'],
      messageText: json['MessageText'],
      messageRich: json['MessageRich'],
      category: json['Category'],
      type: json['Type'],
      layout: json['Layout'],
      priority: json['Priority'],
      status: json['Status'],
      imageUrl: json['ImageUrl'],
      iconUrl: json['IconUrl'],
      actions: (json['Actions'] as List)
          .map((e) => NotificationAction.fromJson(e))
          .toList(),
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
    );
  }
}
