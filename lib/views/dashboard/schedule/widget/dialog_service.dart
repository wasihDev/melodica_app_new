import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart'; // Adjust based on your path
import 'package:melodica_app_new/constants/app_colors.dart'; // Adjust path

class DialogService {
  static void showConsumeCancellationDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              "You’re about to consume your Cancellation.\nWould like to proceed?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context), // Close dialog
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("No"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22), // Orange color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Yes"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 1. showLateNoticeDialog
  static void showLateNoticeDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF27E2B),
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              "Late notice! Reschedule to an earlier date or pay a recovery fee.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "No, thanks",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF27E2B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/dirham.svg',
                          color: Colors.white,
                          height: 12,
                          width: 12,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "50",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. _showConsumePopup (Made static and accessible)
  static Future<bool> showConsumePopup(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Icon(Icons.warning, color: Colors.orange, size: 40),
            content: const Text(
              "A one-time consideration will be applied",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context, true);
                  onConfirm();
                },
                child: Container(
                  height: 50,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Ok",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // 3. _showNotEnoughExtensionPopup
  static void showNotEnoughExtensionPopup(
    BuildContext context, {
    required String title,
    required String payment,
    required VoidCallback ontap,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsPadding: const EdgeInsets.only(bottom: 20, right: 10),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Colors.white,
        title: const Icon(Icons.warning, color: Colors.orange, size: 40),
        content: Text(title, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "No, thanks",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: ontap,
            child: Container(
              height: 50,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/dirham.svg',
                      color: Colors.black,
                      height: 12,
                      width: 12,
                    ),
                    Text(
                      " $payment",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. _showNotEnoughCancellationPopup
  static void showNotEnoughCancellationPopup(
    BuildContext context, {
    required VoidCallback ontap,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsPadding: const EdgeInsets.only(bottom: 20, right: 10),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Colors.white,
        title: const Icon(Icons.warning, color: Colors.orange, size: 40),
        content: const Text(
          "You do not have cancellation allowance. A recovery fee is required to proceed.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "No, thanks",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: ontap,
            child: Container(
              height: 50,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/dirham.svg',
                    color: Colors.black,
                    height: 12,
                    width: 12,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "50",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. showSuccessDialog
  static void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 45.h,
                  width: 45.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF47C97E),
                      width: 4,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: 30.adaptSize,
                      color: const Color(0xFF47C97E),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Your request has been submitted.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.adaptSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff636363),
                  ),
                ),
                Text(
                  "You will receive an update shortly. Your schedule may take up to 2 hours to reflect the changes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.adaptSize,
                    color: const Color(0xff636363),
                  ),
                ),
                SizedBox(height: 15.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF47C97E),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Okay',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// new popoups
  static Future<bool> showNoMorePaidPopup(
    BuildContext context, {
    required String title,
    required VoidCallback onConfirm,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Icon(Icons.warning, color: Colors.orange, size: 40),
            content: Text("$title", textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context, true);
                  onConfirm();
                },
                child: Container(
                  height: 50,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Ok",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
