import 'package:flutter/material.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/home/faq/help_center_details.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenter extends StatelessWidget {
  const HelpCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Help'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _launchUrl('https://melodica.ae/faq');
              },
              child: Container(
                height: 80.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[500]!),
                ),
                child: ListTile(
                  title: Text(
                    'FAQ\'s',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.fSize,
                    ),
                  ),
                  subtitle: Text(
                    'Have a look at some frequently asked questions to find answers',
                    style: TextStyle(fontSize: 12.fSize),
                  ),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpCenterDetails()),
                );
              },
              child: Container(
                height: 80.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[500]!),
                ),
                child: ListTile(
                  title: Text(
                    'Help Center',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.fSize,
                    ),
                  ),
                  subtitle: Text(
                    'In case you still need help, here you can select a topic and speak to a representative',
                    style: TextStyle(fontSize: 12.fSize),
                  ),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
