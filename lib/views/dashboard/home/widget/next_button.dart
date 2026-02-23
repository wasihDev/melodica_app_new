import 'package:flutter/material.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';

class NextButton extends StatelessWidget {
  final void Function()? onPressed;
  const NextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10.h),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF7CD3C),
            foregroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Next',
            style: TextStyle(fontSize: 18.fSize, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
