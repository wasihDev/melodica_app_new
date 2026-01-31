import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:melodica_app_new/models/notification_model.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetailScreen extends StatefulWidget {
  final AppNotification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  void initState() {
    final provider = context.read<NotificationProvider>();
    provider.markAsRead(widget.notification.notificationId);
    super.initState();
  }

  Future<void> _handleNotificationAction(
    BuildContext context,
    NotificationAction action,
    String notificationId,
  ) async {
    final provider = context.read<NotificationProvider>();

    switch (action.actionType) {
      /// 💳 Payment / Checkout
      case 'payment':
        Navigator.pushNamed(
          context,
          action.route!,
          arguments: action.routeParams,
        );
        break;

      /// 📱 Open WhatsApp
      case 'open_whatsapp':
        if (action.url != null) {
          await launchUrl(
            Uri.parse(action.url!),
            mode: LaunchMode.externalApplication,
          );
        }
        break;

      /// 📲 Open Any Screen
      case 'open_screen':
        Navigator.pushNamed(
          context,
          action.route!,
          arguments: action.routeParams,
        );
        break;

      /// 🌐 Open Web URL
      case 'open_url':
        if (action.url != null) {
          await launchUrl(
            Uri.parse(action.url!),
            mode: LaunchMode.externalApplication,
          );
        }
        break;

      default:
        debugPrint('Unknown action: ${action.actionType}');
    }

    /// ✅ Mark as read if required
    if (action.dismissOnTap) {
      provider.markAsRead(notificationId);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.notification.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Text(
              //   widget.notification.messageText,
              //   style: const TextStyle(fontSize: 16),
              // ),
              // const Spacer(),
              widget.notification.messageRich != null &&
                      widget.notification.messageRich.isNotEmpty
                  ? MarkdownBody(
                      data: widget.notification.messageRich,
                      styleSheet: MarkdownStyleSheet(
                        h2: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        p: const TextStyle(fontSize: 16),
                      ),
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(
                            Uri.parse(href),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    )
                  : Text(
                      widget.notification.messageText,
                      style: const TextStyle(fontSize: 16),
                    ),
              SizedBox(height: 10),

              widget.notification.imageUrl == '' ||
                      widget.notification.imageUrl == null
                  ? SizedBox()
                  : Container(
                      height: 300.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: NetworkImage(
                            widget.notification.imageUrl ?? "",
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 10),
              Spacer(),
              ...widget.notification.actions.map(
                (action) => SafeArea(
                  bottom: true,
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.notification.isValidNow == false
                            ? Colors.grey
                            : Colors.amber,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: widget.notification.isValidNow == false
                          ? null
                          : () async {
                              await _handleNotificationAction(
                                context,
                                action,
                                widget.notification.notificationId,
                              );
                              // provider.markAsRead(notification.notificationId);
                              // Navigator.pop(context);
                            },
                      child: Text(
                        action.label,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              // OutlinedButton(
              //   onPressed: () {

              //     Navigator.pop(context);
              //   },
              //   child: const Text(
              //     'Mark as read',
              //     style: TextStyle(color: Colors.black),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
