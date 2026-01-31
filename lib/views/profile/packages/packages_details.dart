import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/views/profile/packages/freez_screen.dart';

class PackageDetailScreen extends StatelessWidget {
  final Package package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final remainingFreezes =
        package.totalAllowedFreezings - package.totalFreezingTaken;

    // print(' package.totalFreezingTaken ${package.totalFreezingTaken}');
    // print('package ${package.cl}')
    final unbookedClasses = package.totalClasses - package.totalBooked;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Package Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title + Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      package.itemName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  package.packageStatus.contains('Completed')
                      ? SizedBox()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Active",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ],
              ),

              // const SizedBox(height: 6),
              // const Text(
              //   "Number of sessions, Frequency, Duration, Package",
              //   style: TextStyle(color: Colors.grey),
              // ),
              const SizedBox(height: 12),

              /// Chips Row
              Wrap(
                spacing: 8,
                children: [
                  _chip(package.locationName),
                  _chip(package.classFrequency),
                  _chip(package.classDuration),
                ],
              ),

              const SizedBox(height: 24),

              /// Remaining Sessions
              const Text(
                "Remaining Classes:",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: package.totalClasses > 0
                      ? (package.remainingSessions / package.totalClasses)
                            .clamp(0.0, 1.0)
                      : 0.0,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFF5C542)),
                ),
              ),

              const SizedBox(height: 20),

              /// Stats Cards
              Row(
                children: [
                  _statCard("Total Classes", package.totalClasses.toString()),
                  const SizedBox(width: 12),
                  _statCard(
                    "Remaining Classes",
                    package.remainingSessions.toString().split(".").first,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),

              /// Details
              _detail("Teacher", package.teacherName),
              _detail("Location", package.locationName),
              _detail(
                "Remaining Cancellation",
                "${package.remainingCancellations}/${package.totalAllowedCancellation}",
              ),
              _detail("Remaining Freezing", "$remainingFreezes"),
              _detail("Unbooked Classes", unbookedClasses.toString()),

              const Spacer(),
            ],
          ),
        ),
      ),

      /// Bottom Buttons
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text(package.totalAllowedFreezings),
              package.packageStatus == "Completed"
                  ? SizedBox()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5C542),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FreezingRequestScreen(package: package),
                          ),
                        );
                      },
                      child: const Text(
                        "Freeze",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
              const SizedBox(height: 20),
              // package.packageStatus == "Completed"
              //     ? SizedBox()
              //     : OutlinedButton(
              //         style: OutlinedButton.styleFrom(
              //           minimumSize: const Size(double.infinity, 48),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(30),
              //           ),
              //         ),
              //         onPressed: () {
              //           showFreezingDialog(
              //             context,
              //             onYes: () {
              //               Navigator.pop(context);
              //               Navigator.pop(context);
              //             },
              //           );
              //         },
              //         child: const Text("Convert"),
              //       ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showFreezingDialog(
    BuildContext context, {
    required VoidCallback onYes,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF5C542),
                    size: 36,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                const Text(
                  "You’re about to consume your Freezing.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  "Would like to proceed?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onYes();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5C542),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Yes",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// --- Small UI Helpers ---

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
