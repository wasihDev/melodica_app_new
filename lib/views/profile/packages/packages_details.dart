import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/profile/packages/freez_screen.dart';
import 'package:melodica_app_new/views/profile/packages/widget/tabbar_view_package_widget.dart';
import 'package:provider/provider.dart';

class PackageDetailScreen extends StatefulWidget {
  final Package package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((va) async {
      final provider = context.read<PackageProvider>();
      //"893979",
      //"100314131",
      await provider.fetchRescheduleRequests(
        clientId: widget.package.clientId,
        packageId: widget.package.paymentRef,
      );
      print('api hit =======>>>');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final remainingFreezes =
        widget.package.totalAllowedFreezings -
        widget.package.totalFreezingTaken;

    final unbookedClasses =
        widget.package.totalClasses - widget.package.totalBooked;

    // print("unbookedClasses ${unbookedClasses.isNegative}");
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title + Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.package.serviceandproduct,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    widget.package.packageStatus.contains('Active') ||
                            widget.package.packageStatus.contains('On Going')
                        ? Container(
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
                          )
                        : SizedBox(),
                  ],
                ),

                const SizedBox(height: 12),

                /// Chips Row
                Wrap(
                  spacing: 8,
                  children: [
                    _chip(widget.package.locationName),
                    Visibility(
                      visible: widget.package.subject != "Dance Classes",
                      child: _chip(widget.package.classFrequency),
                    ),
                    Visibility(
                      visible: widget.package.subject != "Dance Classes",
                      child: _chip(widget.package.classDuration),
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.package.subject != "Dance Classes",
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      const Divider(color: Color(0xffE2E2E2)),
                    ],
                  ),
                ),
                //

                /// Remaining Sessions
                Visibility(
                  visible: widget.package.subject != "Dance Classes",
                  child: const Text(
                    "Remaining Classes:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Visibility(
                  visible: widget.package.subject != "Dance Classes",
                  child: const SizedBox(height: 8),
                ),

                Visibility(
                  visible: widget.package.subject != "Dance Classes",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: widget.package.totalClasses > 0
                          ? (widget.package.remainingSessions /
                                    widget.package.totalClasses)
                                .clamp(0.0, 1.0)
                          : 0.0,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFF5C542),
                      ),
                    ),
                  ),
                ),

                Visibility(
                  visible: widget.package.subject != "Dance Classes",
                  child: const SizedBox(height: 20),
                ),

                /// Stats Cards
                widget.package.subject == "Dance Classes"
                    ? SizedBox()
                    : Row(
                        children: [
                          _statCard(
                            "Total Classes",
                            widget.package.totalClasses.toString(),
                          ),
                          const SizedBox(width: 12),
                          _statCard(
                            "Remaining Classes",
                            widget.package.remainingSessions
                                .toString()
                                .split(".")
                                .first,
                          ),
                        ],
                      ),

                SizedBox(height: 10.h),
                const Divider(color: Color(0xffE2E2E2)),

                /// Details
                _detail("Teacher:", widget.package.teacherName),
                _detail("Location:", widget.package.locationName),

                Visibility(
                  visible:
                      widget.package.subject != "Dance Classes" ||
                      widget.package.remainingCancellations <= 0,
                  child: _detail(
                    "Remaining Cancellation (Classes):",
                    "${widget.package.remainingCancellations}/${widget.package.totalAllowedCancellation}",
                  ),
                ),
                widget.package.subject == "Dance Classes" ||
                        remainingFreezes <= 0
                    ? SizedBox()
                    : _detail(
                        "Remaining Freezing (Weeks):",
                        "${remainingFreezes}/${widget.package.totalAllowedFreezings}",
                      ),
                unbookedClasses.isNegative
                    ? SizedBox()
                    : _detail("Unscheduled Classes:", "${unbookedClasses}"),
                _detail(
                  "Package Expiry:",
                  "${DateFormat('d MMM yyyy').format(DateTime.parse(widget.package.packageExpiry))}",
                ),
                SizedBox(height: 10.h),
                const Divider(color: Color(0xffE2E2E2)),
                SizedBox(height: 10.h),
                PackageScheduleTabs(package: widget.package),
              ],
            ),
          ),
        ),
      ),

      /// Bottom Buttons
      bottomNavigationBar:
          widget.package.packageStatus != "Active" &&
              widget.package.packageStatus != 'On Going'
          ? SizedBox()
          : SafeArea(
              bottom: true,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: Platform.isIOS ? 0 : 16.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 45.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.read<PackageProvider>().resetEndDate();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FreezingRequestScreen(package: widget.package),
                          ),
                        );
                      },
                      child: const Text(
                        "Freeze",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
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
