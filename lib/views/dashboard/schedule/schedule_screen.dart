import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/schedule_model.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/utils/date_format.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/schedule/reschedule_screen.dart';
import 'package:melodica_app_new/views/dashboard/schedule/widget/dialog_widgets.dart';
import 'package:melodica_app_new/widgets/appointment_card.dart';
import 'package:melodica_app_new/widgets/custom_app_bar.dart';
import 'package:melodica_app_new/widgets/date_cell.dart' as d;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime? selectedDate;
  final ScrollController _scrollController = ScrollController();
  void _scrollToDate(
    DateTime selectedDate,
    Map<String, List<dynamic>> grouped,
  ) {
    int index = 0;

    for (final entry in grouped.entries) {
      final date = DateTime.parse(entry.key);

      if (DateUtils.isSameDay(date, selectedDate)) {
        const headerHeight = 40.0;
        const cardHeight = 110.0;

        _scrollController.animateTo(
          index.toDouble(),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        return;
      }

      // Calculate height of this section
      index += 40; // header
      index += entry.value.length * 110; // cards
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    // print('provider ${provider.schedules.length}');
    // print('provider ${provider.upcomingSchedules.length}');
    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final schedules = provider.upcomingSchedules;

    if (schedules.isEmpty) {
      return const Scaffold(body: Center(child: Text('No upcoming classes')));
    }

    /// Default selected date = first class date
    selectedDate ??= schedules.first.bookingDateTime;

    /// Group by date
    final grouped = <String, List<ScheduleModel>>{};
    for (final s in schedules) {
      final key = DateFormat(
        'yyyy-MM-dd',
      ).format(s.bookingDateTime ?? DateTime.now());
      grouped.putIfAbsent(key, () => []).add(s);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          const Divider(),
          SizedBox(height: 16.h),

          /// SELECT DATE HEADER
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 24),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: const [
          //       Text(
          //         'Select Date',
          //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          //       ),
          //       Icon(Icons.keyboard_arrow_down),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 16),

          /// WEEK DATE PICKER
          // SizedBox(
          //   height: 80,
          //   child: ListView.builder(
          //     scrollDirection: Axis.horizontal,
          //     padding: const EdgeInsets.symmetric(horizontal: 24),
          //     itemCount: grouped.keys.length,
          //     itemBuilder: (_, i) {
          //       final dateKey = grouped.keys.elementAt(i);
          //       final date = DateTime.parse(dateKey);

          //       return DateCell(
          //         dayOfWeek: DateFormat('EE').format(date),
          //         dayOfMonth: DateFormat('d').format(date),
          //         isSelected: DateUtils.isSameDay(selectedDate, date),
          //         isHighlighted: false,
          //         onTap: () {
          //           setState(() => selectedDate = date);
          //         },
          //       );
          //     },
          //   ),
          // ),
          d.CustomWeeklyDatePicker(),

          const SizedBox(height: 16),
          // time range filter

          /// APPOINTMENT LIST
          Expanded(
            child: Consumer<ScheduleProvider>(
              builder: (context, provider, _) {
                if (provider.selectedDate != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToDate(provider.selectedDate!, grouped);
                  });
                }
                return ListView(
                  controller: _scrollController,

                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: grouped.entries.map((entry) {
                    final date = DateTime.parse(entry.key);
                    final items = entry.value;

                    final isSelectedDate =
                        provider.selectedDate != null &&
                        DateUtils.isSameDay(provider.selectedDate!, date);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// DATE HEADER
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            DateFormat('EEE, d MMM yyyy').format(date),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        /// CARDS
                        ...items.map((s) {
                          return AppointmentCard(
                            dayOfWeek: s.bookingDay,
                            dayOfMonth: s.day,
                            month: s.monthShort,
                            courseName: s.subject,
                            teacher: s.bookingResource,
                            time: s.time,
                            isSelected: isSelectedDate,
                            // isSelected: DateUtils.isSameDay(selectedDate, date),
                            onTap: () {
                              showAppointmentBottomSheet(context, s);
                            },
                          );
                        }),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),

          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  void showAppointmentBottomSheet(BuildContext context, ScheduleModel s) {
    final expiryDate = DateTime.parse(s.PackageExpiry);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Handle Bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Header Date
                Text(
                  formatCreatedOn(s.bookingDateStartTime).isEmpty
                      ? ""
                      : formatCreatedOn(s.bookingDateStartTime),
                  //  'Tue, 18 Nov 2025',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Info Section Card
                Consumer<CustomerController>(
                  builder: (context, ctrl, child) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Location', '${s.bookingLocation}'),
                          _buildInfoRow('Time', '${s.bookingDateStartTime}'),
                          _buildInfoRow(
                            'Student',
                            '${ctrl.selectedStudent!.fullName}',
                          ),
                          _buildInfoRow('Teacher', '${s.bookingResource}'),
                          _buildInfoRow(
                            'Cancellation',
                            '${s.RemainingCancellations}',
                          ),
                          // DateFormat('dd/MM/yyyy hh:mm a').parse(PackageExpiry);
                          _buildInfoRow(
                            'Expiry',
                            '${DateFormat('dd MMM yyyy').format(expiryDate)}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Note Box
                Container(
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
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),

                      // DateFormat('dd/MM/yyyy hh:mm a').parse(PackageExpiry);
                      Text(
                        'Reschedule before the ${DateFormat('dd MMM yyyy').format(expiryDate)} to avoid using your cancellation.',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      ///call get availablity api

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RescheduleScreen(s: s),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD152), // Yellow button
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reschedule',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {
                      final DateTime bookingdata = DateFormat(
                        'dd/MM/yyyy hh:mm a',
                      ).parse(s.bookingDateStartTime);
                      // Current datetime
                      final DateTime now = DateTime.now();
                      final DateTime today = DateTime(
                        now.year,
                        now.month,
                        now.day,
                      );
                      final DateTime scheduledDay = DateTime(
                        bookingdata.year,
                        bookingdata.month,
                        bookingdata.day,
                      );
                      print('NOW =====>>> $now');
                      print('SCHEDULED =====>>> $bookingdata');

                      // Show late notice if now is equal OR after scheduled time
                      if (today == scheduledDay) {
                        showLateNoticeDialog(context);
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (context) => EarlyNoticeDialog(s: s),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLateNoticeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Orange Warning Icon
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF27E2B), // Matches the orange in your screenshot
              size: 80,
            ),
            const SizedBox(height: 16),

            // Main Text Content
            const Text(
              "Late notice! This will consume cancellation.\nConsider paying recovery fee to book.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // "No, thanks" Button
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

                // "AED 50" Payment Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final servicesProvider = Provider.of<ServicesProvider>(
                        context,
                        listen: false,
                      );
                      servicesProvider.setPaymentType(
                        PaymentType.freezingPoints,
                      );
                      final vat = 50 * 0.05;
                      final amountWithVat = (50 + vat).toInt();

                      final success = await servicesProvider.startCheckout(
                        context,
                        amount: amountWithVat,
                        redirectUrl: "https://melodica-mobile.web.app",
                      );

                      if (success && servicesProvider.paymentUrl != null) {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        await launchUrl(
                          Uri.parse(servicesProvider.paymentUrl!),
                          mode: LaunchMode.externalApplication,
                        );
                      }
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
                    child: const Text(
                      "AED ${50 * 1.05}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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

  // Helper widget for information rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF2D3436),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String format(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  // Widget _timeBox(
  //   BuildContext context, {
  //   required String label,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  //       decoration: BoxDecoration(
  //         color: Colors.grey.shade100,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Row(
  //         children: [
  //           Text(label),
  //           const SizedBox(width: 6),
  //           const Icon(Icons.arrow_drop_down),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
