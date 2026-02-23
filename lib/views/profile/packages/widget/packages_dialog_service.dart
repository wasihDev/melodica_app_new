import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/whatsapp_link.dart';
import 'package:melodica_app_new/views/dashboard/home/faq/help_center.dart';

class PopupService {
  // ================= Next Class Info =================
  static Future<void> showNextClassInfoPopup(
    BuildContext context,
    DateTime nextClass, {
    VoidCallback? onNo,
    VoidCallback? onYes,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          content: Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Text(
              "Your Next Class will be on\n"
              "${DateFormat('d MMM yyyy').format(nextClass)}",
              textAlign: TextAlign.center,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppColors.primary),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    // Handle result via callbacks
    if (result == false) {
      onNo?.call();
    } else if (result == true) {
      onYes?.call();
    }
  }

  static void showNoUpcomingClassesPopup(
    BuildContext context,
    endDate,
    startDate,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Freezing request submitted!",
            style: TextStyle(fontSize: 16.fSize, fontWeight: FontWeight.w600),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: const Text(
              'We will get in touch to schedule your upcoming classes',
              textAlign: TextAlign.center,
            ),
          ),

          actionsOverflowButtonSpacing: 0,
          actionsPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 30.h,
          ),
          actionsAlignment: MainAxisAlignment.center,
          // actionsOverflowAlignment: OverflowBarAlignment.,
          // actionsPadding: EdgeInsets.all(0),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppColors.primary),
              ),
              onPressed: () async {
                Navigator.pop(context);
                endDate = null;
                startDate = null;
                launchWhatsApp(
                  'Hello, I have submitted a freezing request and would like help scheduling my upcoming classes. Please assist me.',
                );
              },
              child: const Text("Okay", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  static void showNotEnoughFreezingPopup(
    BuildContext context,
    String danceOrmusic, {
    required String price,
    required VoidCallback ontap,
  }) {
    showDialog(
      context: context,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 18),
                Icon(Icons.warning, color: Colors.orange, size: 40),
                SizedBox(height: 25),

                Text(
                  danceOrmusic == "Dance Classes"
                      ? "You do not have enough remaining freezing allowance.\nAn extension fee is required to proceed"
                      : "You do not have enough freezing allowance. We recommend rescheduling your classes in advance to avoid extra fee.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    danceOrmusic == "Dance Classes"
                        ? SizedBox()
                        : Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.dashboard,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              splashColor: AppColors.primary.withOpacity(0.2),
                              highlightColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child: Ink(
                                height: 45.h,
                                width: 110.w,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                // alignment: Alignment.center,
                                child: Center(
                                  child: Text(
                                    'Reschedule',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.fSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    InkWell(
                      onTap: ontap,
                      child: Container(
                        height: 50,
                        width: 110.w,
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
                                height: 10.h,
                                width: 10.w,
                              ),
                              Text(
                                " $price",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.fSize,
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "No, thanks",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.fSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showSuccessPopup(BuildContext context, endDate, startDate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Icon(Icons.check_circle, color: Colors.green, size: 40),
        content: Text(
          "Your request has been submitted.\nYour schedule may take up to 2 hours to reflect the changes.",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          InkWell(
            onTap: () {
              endDate = null;
              startDate = null;
              // resetEndDate(p);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "OK",
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
    );
  }

  static void showRestrictedFreezingPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 60),
            const SizedBox(height: 16),
            const Text(
              "You do not have freezing allowance, consider rescheduling in advance to avoid session loss.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F), // Melodica Yellow
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showNotCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Welcome to Melodica 🎵",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "It looks like you don’t have an active Melodica account yet.\n\n"
              "This app is currently available for Melodica students only. "
              "If you believe this is a mistake, please contact your branch.",
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpCenter()),
                  );
                  // Navigator.pop(context);
                },
                child: const Text(
                  "Help Center",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (_) => false,
                  );
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showErrorPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Icon(Icons.error_outline, color: Colors.red, size: 44),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
