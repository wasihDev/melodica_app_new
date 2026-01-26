import 'package:flutter/material.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/receipt_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/webview_online_store.dart';

const kYellow = Color(0xFFFFD34D);
const kLightGrey = Color(0xFFF6F6F6);
const kBorderGrey = Color(0xFFE0E0E0);
const kGreen = Color(0xFF4CAF50);

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.0),
        child: PrimaryButton(
          text: 'Next',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReceiptScreen()),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: kBorderGrey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: kGreen, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Thank you for enrolling!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kGreen,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Do you have a piano to practice on?\n'
                'We have amazing offers on pianos\n'
                'available for our students',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WebViewPage(
                          url: 'https://melodicamusicstore.com/',
                          title: 'Online Store',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Visit Store',
                    style: TextStyle(color: Colors.white),
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
