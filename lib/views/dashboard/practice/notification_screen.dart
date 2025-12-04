import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedTab = 0; // 0 = All, 1 = Read, 2 = Unread

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Basics of Piano',
      'subtitle': 'Class of Ms Sara',
      'time': '4:00PM',
      'isRead': false,
      'dateGroup': 'Today',
    },
    {
      'title': 'Basics of Piano',
      'subtitle': 'Class of Ms Sara',
      'time': '4:00PM',
      'isRead': true,
      'dateGroup': 'Yesterday',
    },
    {
      'title': 'Basics of Piano',
      'subtitle': 'Class of Ms Sara',
      'time': '4:00PM',
      'isRead': true,
      'dateGroup': 'Yesterday',
    },
    {
      'title': 'Basics of Piano',
      'subtitle': 'Class of Ms Sara',
      'time': '4:00PM',
      'isRead': false,
      'dateGroup': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(child: _buildNotificationList()),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.arrow_back, size: 26),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const Icon(Icons.notifications_active_outlined, size: 26),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabItem(label: 'All', index: 0, count: notifications.length),
          const SizedBox(width: 8),
          _buildTabItem(
            label: 'Read',
            index: 1,
            count: notifications.where((e) => e['isRead']).length,
          ),
          const SizedBox(width: 8),
          _buildTabItem(
            label: 'Unread',
            index: 2,
            count: notifications.where((e) => !e['isRead']).length,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required int index,
    required int count,
  }) {
    final bool active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.black : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: active ? Colors.black : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    List<Map<String, dynamic>> filtered = notifications;

    if (selectedTab == 1) {
      filtered = notifications.where((e) => e['isRead']).toList();
    } else if (selectedTab == 2) {
      filtered = notifications.where((e) => !e['isRead']).toList();
    }

    // Group by Today / Yesterday
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in filtered) {
      grouped.putIfAbsent(item['dateGroup'], () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: grouped.entries.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                group.key,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...group.value.map((item) => _buildNotificationCard(item)).toList(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    bool isUnread = !item['isRead'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFFF7E1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () {
          // Navigator.pushNamed(context, AppRoutes.notificationPreview);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle'],
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Text(
              item['time'],
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD54F),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text(
            'Next',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
