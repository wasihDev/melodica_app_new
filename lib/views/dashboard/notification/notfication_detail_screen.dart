import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:melodica_app_new/constants/global_variables.dart';
import 'package:melodica_app_new/models/notification_model.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
// import 'package:melodica_app_new/utils/upgrade_custom_dialog.dart';
import 'package:melodica_app_new/views/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
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

  Future<void> _loadHomeData() async {
    // final context = context;
    final provider = Provider.of<UserprofileProvider>(context, listen: false);
    final schedule = Provider.of<ScheduleProvider>(context, listen: false);
    final cusprovider = Provider.of<CustomerController>(context, listen: false);
    final package = Provider.of<PackageProvider>(context, listen: false);
    print(
      'cusprovider.isCustomerRegistered ${cusprovider.isCustomerRegistered}',
    );
    // UpdateService.checkVersion(context);
    print('cusprovider.isShowData ${cusprovider.isShowData}');

    if (cusprovider.isShowData.isEmpty) {
      await provider.fetchUserData();
      await cusprovider.fetchCustomerData();
      await cusprovider.upsertCustomer();

      await package.fetchPackages(context);
      await context.read<ServicesProvider>().fetchDancePackages();
      await cusprovider.getDisplayDance(
        cusprovider.selectedBranch ?? cusprovider.customer!.territoryid,
      );
      await provider.loadImageFromPrefs();
      await schedule.fetchSchedule(context);
      await cusprovider.fetchPhoneMeta();

      context.read<NotificationProvider>().fetchNotifications();
    } else {
      context.read<NotificationProvider>().fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifications'),
        leading: InkWell(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              print('=========>> caling if');
            } else {
              _loadHomeData();
              openedFromNotification = false;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (route) => false,
              );
            }
          },
          child: Icon(Icons.arrow_back_ios),
        ),
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
              widget.notification.messageRich != '' &&
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
                            },
                      child: Text(
                        action.label,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
