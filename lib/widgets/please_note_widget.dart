import 'package:flutter/material.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';

class PleaseNoteWidget extends StatelessWidget {
  final String title;
  const PleaseNoteWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EC), // Light cream background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLEASE NOTE',
            style: TextStyle(
              color: Color(0xFFE67E22), // Orange text
              fontWeight: FontWeight.bold,
              fontSize: 14.fSize,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            title,
            style: TextStyle(color: Colors.grey[500]!, fontSize: 12.fSize),
          ),
        ],
      ),
    );
  }
}
