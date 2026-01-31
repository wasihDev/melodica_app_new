import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Models ---
class HelpTopic {
  final String title;
  HelpTopic(this.title);
}

class HelpCategory {
  final String name;
  final List<HelpTopic> topics;
  HelpCategory(this.name, this.topics);
}

class HelpCenterDetails extends StatelessWidget {
  HelpCenterDetails({super.key});
  // Dynamic Data Structure based on your requirements
  final List<HelpCategory> categories = [
    HelpCategory("Music Classes", [
      HelpTopic("Class rescheduling"),
      HelpTopic("Make-up classes"),
      HelpTopic("Teacher enquiries"),
    ]),
    HelpCategory("Dance Classes", [
      HelpTopic("Class uniform"),
      HelpTopic("Levels & placement"),
      HelpTopic("Booking questions"),
    ]),
    HelpCategory("Packages & Payments", [
      HelpTopic("Renewals"),
      HelpTopic("Freezing packages"),
      HelpTopic("Billing questions"),
    ]),
    HelpCategory("Branches & Locations", [
      HelpTopic("Branch timings"),
      HelpTopic("Closest branch"),
      HelpTopic("Facilities"),
    ]),
    HelpCategory("Instruments & Retail", [
      HelpTopic("Purchase queries"),
      HelpTopic("Instrument servicing"),
      HelpTopic("Warranty & returns"),
    ]),
    HelpCategory("Account & App Support", [
      HelpTopic("Login help"),
      HelpTopic("Editing profile details"),
      HelpTopic("App technical issues"),
    ]),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Help Center Details'),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                title: Text(
                  categories[index].name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TopicDetailScreen(category: categories[index]),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Detail Screen (WhatsApp Routing) ---
class TopicDetailScreen extends StatelessWidget {
  final HelpCategory category;
  const TopicDetailScreen({super.key, required this.category});

  // The logic for opening WhatsApp
  Future<void> launchWhatsApp(String topicName) async {
    final phone = '97145591000';
    final message =
        'Hello, I need assistance. Kindly help me regarding my query.\n\n'
        'Topic: $topicName';
    final encodedMessage = Uri.encodeComponent(message);

    Uri url;

    if (Platform.isAndroid) {
      url = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMessage');
    } else {
      // Web or unsupported platform
      url = Uri.parse(
        'https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage',
      );
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch WhatsApp. Make sure the app is installed.');
      // Optional: show alert to user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          category.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.topics.length,
        itemBuilder: (context, index) {
          final topic = category.topics[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                title: Text(
                  topic.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/124/124034.png", // WhatsApp Icon
                  width: 24,
                  height: 24,
                ),
                onTap: () => launchWhatsApp(topic.title),
              ),
            ),
          );
        },
      ),
    );
  }
}
