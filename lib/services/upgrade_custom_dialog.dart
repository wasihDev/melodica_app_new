import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class UpdateService {
  // Replace with your actual IDs
  static const String androidPackageName = 'com.melodica_app_new';
  static const String iOSAppId = '6756521272';

  static Future<void> checkVersion(BuildContext context) async {
    // 1. Get current local version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version; // e.g., "1.0.0"

    String latestVersion = "";

    try {
      if (Platform.isAndroid) {
        latestVersion = await _getAndroidVersion(androidPackageName);
      } else if (Platform.isIOS) {
        latestVersion = await _getIOSVersion(iOSAppId);
      }
      print('latestVersion $latestVersion');
      print('currentVersion $currentVersion');

      // 2. Compare versions

      if (latestVersion.isNotEmpty &&
          _isUpdateAvailable(currentVersion, latestVersion)) {
        _showUpdateDialog(context, latestVersion);
      }
    } catch (e) {
      debugPrint("Version check failed: $e");
    }
  }

  // SCRAPE PLAY STORE (Note: Google changes tags often)
  static Future<String> _getAndroidVersion(String packageName) async {
    final response = await http.get(
      Uri.parse(
        "https://play.google.com/store/apps/details?id=$packageName&hl=en",
      ),
    );
    if (response.statusCode == 200) {
      // Look for the version string in the HTML (regex depends on current Play Store layout)
      final regExp = RegExp(r'\[\[\["(\d+\.\d+\.\d+)"\]\]');
      final match = regExp.firstMatch(response.body);
      return match?.group(1) ?? "";
    }
    return "";
  }

  // QUERY APP STORE (Official iTunes API - very stable)
  static Future<String> _getIOSVersion(String appId) async {
    final response = await http.get(
      Uri.parse("https://itunes.apple.com/lookup?id=$appId"),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('json ======>>> $json');
      if (json['resultCount'] > 0) {
        print('json 2======>>> ${json['results'][0]['version']}');
        return json['results'][0]['version'];
      }
    }
    return "";
  }

  // VERSION COMPARISON LOGIC
  static bool _isUpdateAvailable(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();

    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i])
        return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  // static bool _isUpdateAvailableIOS(String current, String latest) {
  //   List<int> currentParts = current
  //       .split('.')
  //       .map((e) => int.tryParse(e) ?? 0)
  //       .toList();
  //   List<int> latestParts = latest
  //       .split('.')
  //       .map((e) => int.tryParse(e) ?? 0)
  //       .toList();

  //   int maxLength = currentParts.length > latestParts.length
  //       ? currentParts.length
  //       : latestParts.length;

  //   for (int i = 0; i < maxLength; i++) {
  //     int currentValue = i < currentParts.length ? currentParts[i] : 0;
  //     int latestValue = i < latestParts.length ? latestParts[i] : 0;

  //     if (latestValue > currentValue) return true;
  //     if (latestValue < currentValue) return false;
  //   }

  //   return false;
  // }

  // 3. SHOW THE POPUP
  static void _showUpdateDialog(BuildContext context, String newVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // Prevent back button from closing it
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content height
              children: [
                // --- ICON/IMAGE HEADER ---
                CircleAvatar(
                  radius: 40.adaptSize,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.system_update,
                    size: 40.adaptSize,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // --- TITLE ---
                Text(
                  "New Version Available",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // --- CONTENT ---
                Text(
                  "A fresh update ($newVersion) is waiting for you! Update now to enjoy the latest features and improved performance.",
                  style: TextStyle(color: Colors.grey[700], height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // --- ACTIONS ---
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white, // Text color
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _launchStore(),
                        child: const Text(
                          "Update Now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _launchStore() async {
    final url = Platform.isAndroid
        ? "https://play.google.com/store/apps/details?id=$androidPackageName"
        : "https://apps.apple.com/app/id$iOSAppId";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
