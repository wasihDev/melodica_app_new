import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/notification_model.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
import 'package:melodica_app_new/views/dashboard/notification/notfication_detail_screen.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedTab = 0; // 0=All,1=Read,2=Unread

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    final list = selectedTab == 0
        ? provider.all
        : selectedTab == 1
        ? provider.read
        : provider.unread;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            _tabs(provider),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final n = list[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NotificationDetailScreen(notification: n),
                        ),
                      );
                    },
                    child: _notificationTile(n),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs(NotificationProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _tab('All', provider.all.length, 0),
          _tab('Read', provider.read.length, 1),
          _tab('Unread', provider.unread.length, 2),
        ],
      ),
    );
  }

  Widget _tab(String title, int count, int index) {
    final selected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? Colors.amber : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(child: Text('$title $count')),
        ),
      ),
    );
  }

  Widget _notificationTile(AppNotification n) {
    final provider = context.watch<NotificationProvider>();
    final isRead = provider.isNotificationRead(n.notificationId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFFFF6D8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            n.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(n.messageText, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
