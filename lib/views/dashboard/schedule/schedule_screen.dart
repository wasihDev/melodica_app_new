import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/schedule_model.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/utils/date_format.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/schedule/reschedule_screen.dart';
import 'package:melodica_app_new/views/dashboard/schedule/widget/dialog_service.dart';
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
    // final schedules = provider.schedules;

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
          // SizedBox(height: 5.h),

          /// SELECT DATE HEADER
          d.CustomWeeklyDatePicker(),

          // SizedBox(height: 5.h),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                          padding: EdgeInsets.only(top: 12.h, bottom: 0),
                          child: Text(
                            DateFormat('EEE, d MMM yyyy').format(date),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12.fSize,
                              color: Colors.grey[700],
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

  String removingTimeFromDate(String datetime) {
    DateFormat inputFormat = DateFormat("d MMM yyyy hh:mm a");

    // 2. Parse the string into a DateTime object
    DateTime dateTime = inputFormat.parse("${datetime}");

    // 3. Format it back to just the date
    String dateOnly = DateFormat("d MMM yyyy").format(dateTime);
    return dateOnly;
  }

  void showAppointmentBottomSheet(BuildContext context, ScheduleModel s) {
    print('s.PackageExpiry ${s.PackageExpiry}');
    // final expiryDate = DateTime.parse(s.PackageExpiry);
    DateTime? expiryDate;

    if (s.PackageExpiry != null && s.PackageExpiry.isNotEmpty) {
      try {
        expiryDate = DateTime.parse(s.PackageExpiry);
      } catch (e) {
        expiryDate = null;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final DateTime now = DateTime.now();
        final DateTime bookingDate = DateFormat(
          'dd MMM yyyy hh:mm a',
        ).parse(s.bookingDateStartTime);
        final DateTime today = DateTime(now.year, now.month, now.day);
        final DateTime scheduledDay = DateTime(
          bookingDate.year,
          bookingDate.month,
          bookingDate.day,
        );
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
                SizedBox(height: 10.h),

                // Info Section Card
                Consumer<CustomerController>(
                  builder: (context, ctrl, child) {
                    final date = DateFormat(
                      'd MMM yyyy hh:mm a',
                    ).parse(s.bookingDateStartTime);

                    final formatted = DateFormat(
                      'd MMM yyyy h:mm a',
                    ).format(date);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Location', '${s.bookingLocation}'),
                          _buildInfoRow('Time', '${formatted}'),
                          _buildInfoRow(
                            'Student',
                            '${ctrl.selectedStudent!.fullName}',
                          ),
                          _buildInfoRow('Teacher', '${s.bookingResource}'),
                          _buildInfoRow(
                            'Cancellation Left',
                            s.RemainingCancellations < 0
                                ? '0'
                                : '${s.RemainingCancellations}',
                          ),
                          // DateFormat('dd/MM/yyyy hh:mm a').parse(PackageExpiry);
                          _buildInfoRow(
                            'Package Expiry',
                            '${DateFormat('d MMM yyyy').format(expiryDate ?? DateTime.now())}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),

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
                          fontSize: 14.fSize,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      Text(
                        today == scheduledDay
                            ? "This is a late notice. Cancelling this class will result in a same-day cancellation fee. Consider rescheduling to a different time on the same day."
                            : s.RemainingCancellations <= 0
                            ? "You don't have allowable cancellations left. Reschedule before ${removingTimeFromDate(s.bookingDateStartTime)} or pay AED 50 to reschedule it to a later date."
                            : "Reschedule before the ${removingTimeFromDate(s.bookingDateStartTime)} to avoid using your cancellation.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.fSize,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                s.danceOrMusic == "Music Classes"
                    ? SizedBox(
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
                            backgroundColor: const Color(
                              0xFFFFD152,
                            ), // Yellow button
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
                      )
                    : SizedBox(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {
                      final DateTime bookingdata = DateFormat(
                        'dd MMM yyyy hh:mm a',
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
                      final classDateTime = formatStringToApiDate(
                        s.bookingDateStartTime,
                      );
                      // Show late notice if now is equal OR after scheduled time
                      if (today == scheduledDay) {
                        DialogService.showLateNoticeDialog(
                          context,
                          onConfirm: () async {
                            final servicesProvider =
                                Provider.of<ServicesProvider>(
                                  context,
                                  listen: false,
                                );
                            final packageProvider =
                                Provider.of<PackageProvider>(
                                  context,
                                  listen: false,
                                );
                            final scheduleProvider = context
                                .read<ScheduleProvider>();
                            servicesProvider.setPaymentType(
                              PaymentType.schedulePoints,
                            );

                            final pro = packageProvider.packages.firstWhere(
                              (n) => n.paymentRef == s.PackageCode.toString(),
                            );

                            final vat = 50 * 0.05;
                            final amountWithVat = (50 + vat).toInt();
                            scheduleProvider.setScheduleRequests(
                              subject: s.subject,
                              classDateTime: classDateTime,
                              action: "Rebook",
                              preferredSlot: "",
                              lateNotice: today == scheduledDay
                                  ? 'Late'
                                  : 'Early',
                              branch: "${pro.branch}",
                              packageId: '${pro.paymentRef}',
                              totalamount: "$amountWithVat",
                            );
                            final success = await servicesProvider
                                .startCheckout(context, amount: amountWithVat);
                            if (success &&
                                servicesProvider.paymentUrl != null) {
                              final requestReturn = await scheduleProvider
                                  .submitScheduleRequestAfterPayment(
                                    servicesProvider.orderReference!,
                                    prints: '',
                                  );
                              if (requestReturn) {
                                Navigator.pop(context);
                                await launchUrl(
                                  Uri.parse(servicesProvider.paymentUrl!),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            }
                          },
                        );

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

  // Helper widget for information rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey, fontSize: 12.fSize),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.fSize,
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

  String formatStringToApiDate(String dateString) {
    try {
      final parsedDate = DateFormat('dd MMM yyyy hh:mm a').parse(dateString);
      return parsedDate.toUtc().toIso8601String().split('.').first + 'Z';
    } catch (e) {
      print("Error parsing date string: $e");
      return dateString;
    }
  }
}
