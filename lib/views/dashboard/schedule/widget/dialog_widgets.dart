import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/schedule_model.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:provider/provider.dart' show Consumer, Provider;

class EarlyNoticeDialog extends StatelessWidget {
  ScheduleModel s;
  EarlyNoticeDialog({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    // print();
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            "Are you sure you want to cancel?\n${s.danceOrMusic == "Dance Classes" ? "" : "You can reschedule to avoid losing it."}",
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
                    Navigator.pop(context); // Close this dialog first
                    Navigator.pop(context); // Close this dialog first
                    // Then show the bottom sheet for reason selection
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => SafeArea(
                        bottom: true,
                        child: CancelLessonBottomSheet(s: s),
                      ),
                    );
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
    );
  }
}

// --- 2. Cancel Lesson Bottom Sheet ---
class CancelLessonBottomSheet extends StatefulWidget {
  ScheduleModel s;

  CancelLessonBottomSheet({super.key, required this.s});

  @override
  State<CancelLessonBottomSheet> createState() =>
      _CancelLessonBottomSheetState();
}

class _CancelLessonBottomSheetState extends State<CancelLessonBottomSheet> {
  String? _selectedReason;
  final List<String> _reasons = [
    "Emergency",
    "Personal",
    "Sickness",
    "School Break",
    "Other",
  ];
  String calculateNoticeType(String classDateTime) {
    print('classDateTime $classDateTime');

    final format = DateFormat('dd MMM yyyy hh:mm a');
    final classTime = format.parse(classDateTime);

    final now = DateTime.now();
    final diff = classTime.difference(now);

    return diff.inHours > 24 ? 'Early' : 'Late';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grey drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            "Select a reason for Cancellation",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // List of reasons with radio buttons
          ..._reasons.map(
            (reason) => RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: _selectedReason,
              activeColor: const Color(0xFFFFD152),
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
            ),
          ),
          SizedBox(height: 14.h),
          Consumer<ScheduleProvider>(
            builder: (context, provider, child) {
              return SafeArea(
                bottom: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedReason == null
                        ? null // Disable button if no reason is selected
                        : () async {
                            //   widget.s.bookingDateStartTime
                            // final classdatetime = formatToApiDate(
                            //   DateTime.now(),
                            //   // widget.s.bookingDateStartTime,
                            // );
                            // Show final confirmation dialog
                            final Packageprovider =
                                Provider.of<PackageProvider>(
                                  context,
                                  listen: false,
                                );
                            final pro = Packageprovider.packages.firstWhere(
                              (n) =>
                                  n.paymentRef ==
                                  widget.s.PackageCode.toString(),
                            );
                            final noticeType = calculateNoticeType(
                              widget.s.bookingDateStartTime,
                            );
                            print(
                              'classdatetime ${widget.s.bookingDateStartTime}',
                            );
                            print(
                              'classdatetime ${formatToIso8601(widget.s.bookingDateStartTime)}',
                            );
                            await provider
                                .submitScheduleRequest(
                                  subject: widget.s.subject,
                                  classDateTime: formatToIso8601(
                                    widget.s.bookingDateStartTime,
                                  ),
                                  action: 'Forfeit',
                                  preferredSlot: "",
                                  reason: "$_selectedReason",
                                  branch: '${pro.branch}',
                                  packageid: '${pro.paymentRef}',
                                  lateNotic: '$noticeType', // late or early
                                )
                                .then((val) {
                                  if (val) {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const ClassStartedDialog(),
                                    );
                                  } else {
                                    SnackbarUtils.showError(
                                      context,
                                      "We couldn't process the schedule details. Please contact support if this persists. ",
                                    );
                                  }
                                });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: provider.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Cancel Class",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String formatToApiDate(DateTime date) {
    return date.toUtc().toIso8601String().split('.').first + 'Z';
  }

  String formatToIso8601(String dateStr) {
    try {
      DateFormat inputFormat = DateFormat("dd MMM yyyy h:mm a");
      DateTime parsedDate = inputFormat.parse(dateStr);
      String formatted = DateFormat("yyyy-MM-ddTHH:mm:ss").format(parsedDate);
      return "${formatted}Z";
    } catch (e) {
      print("Error parsing date: $e");
      return "";
    }
  }
}

// --- 3. Class Started Dialog (Final Confirmation) ---
class ClassStartedDialog extends StatelessWidget {
  const ClassStartedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
            SizedBox(height: 16),
            Text(
              "Your class has been cancelled.\nSee you in your next class!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.primary),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Okay', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
