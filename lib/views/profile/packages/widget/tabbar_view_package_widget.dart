import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/get_cancellation_model.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/models/schedule_model.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/utils/date_format.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/home_shimmer.dart';
import 'package:melodica_app_new/views/dashboard/schedule/reschedule_screen.dart';
import 'package:melodica_app_new/views/dashboard/schedule/widget/dialog_service.dart';
import 'package:melodica_app_new/views/dashboard/schedule/widget/dialog_widgets.dart';
import 'package:melodica_app_new/widgets/appointment_card.dart';
import 'package:melodica_app_new/widgets/please_note_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 60.0; // Height of your TabBar
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

class PackageScheduleTabs extends StatelessWidget {
  final Package package;
  const PackageScheduleTabs({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    // Watch the provider to rebuild when data is fetched
    final provider = context.watch<ScheduleProvider>();
    final pkgprovider = context.watch<PackageProvider>();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            splashBorderRadius: BorderRadius.circular(30),
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: const EdgeInsets.only(right: 8),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFFFFD54F),
            ),
            tabs: [
              _buildTabHeader("Upcoming"),
              _buildTabHeader("Completed"),
              _buildTabHeader("Cancelled"),
            ],
          ),

          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final tabController = DefaultTabController.of(context);
              return AnimatedBuilder(
                animation: tabController,
                builder: (context, _) {
                  // Determine which list to show based on the active tab
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  Widget currentList;
                  switch (tabController.index) {
                    case 0:
                      currentList = _buildFilteredList(
                        context,
                        allSchedules: provider.upcomingSchedules,
                        reasonFilter: (s) => true,
                        useFilter: false,
                        borderColor: Colors.green,
                        value: tabController,
                      );
                      break;
                    case 1:
                      currentList = _buildFilteredList(
                        context,
                        allSchedules: provider.completedSchedules,
                        reasonFilter: (s) => true,
                        useFilter: false,
                        borderColor: Colors.brown,
                        value: tabController,
                      );
                      break;
                    case 2:
                      currentList = _buildCancelledList(
                        context,
                        pkgprovider.requests,
                        pkgprovider,
                      );

                      break;
                    default:
                      currentList = const SizedBox();
                  }
                  return currentList;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredList(
    BuildContext context, {
    required List<ScheduleModel> allSchedules,
    required bool Function(ScheduleModel) reasonFilter,
    required Color borderColor,
    required TabController value,
    bool useFilter = true, // Add this flag
  }) {
    final filteredList = allSchedules.where((s) {
      bool matchesPackage = s.PackageCode == package.paymentRef;
      bool matchesReason = useFilter ? reasonFilter(s) : true;
      return matchesReason && matchesPackage;
    }).toList();
    final Map<String, List<ScheduleModel>> grouped = {};
    for (var item in filteredList) {
      final dateKey = item.bookingDateTime != null
          ? DateFormat('yyyy-MM-dd').format(item.bookingDateTime!)
          : "Unknown";

      if (grouped[dateKey] == null) grouped[dateKey] = [];
      grouped[dateKey]!.add(item);
    }

    final entries = grouped.entries.toList();

    if (entries.isEmpty) {
      return const Center(child: Text("No classes found."));
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: entries.length,
      shrinkWrap: true,
      // physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final items = entry.value;
        // Parse key back to DateTime for header display
        // final displayDate = DateTime.tryParse(entry.key) ?? DateTime.now();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...items.map(
              (s) => AppointmentCard(
                dayOfWeek: s.bookingDay,
                dayOfMonth: s.day,
                month: s.monthShort,
                courseName: s.subject,
                teacher: s.bookingResource,
                time: s.time,
                isShowActive: true,
                status: value.index == 2
                    ? "${s.cancellation_status}"
                    : s.statusReason,
                color: value.index == 2
                    ? Colors.red
                    : statusColor(s.statusReason),
                onTap: () {
                  showAppointmentBottomSheet(context, s, value.index);
                },
                isSelected: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Color statusColor(String statusReason) {
    Color color;
    switch (statusReason) {
      case "Late Cancel":
        color = Colors.red;
        break;
      case "Completed":
        color = Colors.blue;
        break;
      case "Booked":
        color = Colors.green;
        break;
      case "No Show":
        color = Colors.brown;
        break;
      default:
        color = Colors.amber;
        break;
    }
    return color;
  }

  void showAppointmentBottomSheet(
    BuildContext context,
    ScheduleModel s,
    int tabIndex,
  ) {
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
                    // final expiryDate = DateTime.parse(s.PackageExpiry);
                    DateTime? expiryDate;

                    if (s.PackageExpiry != null && s.PackageExpiry.isNotEmpty) {
                      try {
                        expiryDate = DateTime.parse(s.PackageExpiry);
                      } catch (e) {
                        expiryDate = null;
                      }
                    }
                    print('s.bookingDateStartTime ${s.bookingDateStartTime}');
                    final date = DateFormat(
                      'd MMM yyyy h:mm a',
                    ).parse(s.bookingDateStartTime);

                    final formatted = DateFormat(
                      'd MMM yyyy, h:mm a',
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
                            'Cancellations Left',
                            s.RemainingCancellations <= 0
                                ? "0"
                                : '${s.RemainingCancellations}',
                          ),
                          _buildInfoRow(
                            'Package Expiry',
                            '${DateFormat('d MMM yyyy').format(expiryDate ?? DateTime.now())}  ',
                            //'${DateFormat('dd MMM yyyy').format(expiryDate)}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Note Box
                // Note Box
                PleaseNoteWidget(
                  title: today == scheduledDay
                      ? "This is a late notice. Cancelling this class will result in a same-day cancellation fee. Consider rescheduling to a different time on the same day."
                      : s.RemainingCancellations <= 0
                      ? "You don't have allowable cancellations left. Reschedule before ${removingTimeFromDate(s.bookingDateStartTime)} or pay AED 50 to reschedule it to a later date."
                      : "Reschedule before the ${removingTimeFromDate(s.bookingDateStartTime)} to avoid using your cancellation.",

                  // title: today == scheduledDay
                  //     ? "This is a late notice. Cancelling this class will result in a same-day cancellation fee. Consider rescheduling to a different time on the same day."
                  // : "Reschedule before the ${removingTimeFromDate(s.bookingDateStartTime)} to avoid using your cancellation.",
                ),

                const SizedBox(height: 24),

                // Action Buttons
                tabIndex >= 1
                    ? SizedBox()
                    : s.danceOrMusic == "Music Classes"
                    ? SizedBox(
                        width: double.infinity,
                        height: 50,
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
                tabIndex >= 1
                    ? SizedBox()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
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

                                  final pro = packageProvider.packages
                                      .firstWhere(
                                        (n) =>
                                            n.paymentRef ==
                                            s.PackageCode.toString(),
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
                                      .startCheckout(
                                        context,
                                        amount: amountWithVat,
                                      );
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

  String formatStringToApiDate(String dateString) {
    try {
      final parsedDate = DateFormat('dd MMM yyyy hh:mm a').parse(dateString);
      return parsedDate.toUtc().toIso8601String().split('.').first + 'Z';
    } catch (e) {
      print("Error parsing date string: $e");
      return dateString;
    }
  }

  String removingTimeFromDate(String datetime) {
    DateFormat inputFormat = DateFormat("d MMM yyyy hh:mm a");
    DateTime dateTime = inputFormat.parse("${datetime}");
    String dateOnly = DateFormat("d MMM yyyy").format(dateTime);
    return dateOnly;
  }

  Widget _buildTabHeader(String title) {
    return Tab(
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.black, fontSize: 12.fSize),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 115.w,
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

  Widget _buildCancelledList(
    BuildContext context,
    List<GetCancellationModel> list,
    PackageProvider pkg,
  ) {
    if (pkg.isloading) {
      return HomeShimmer();
    }
    if (list.isEmpty) {
      return const Center(child: Text("No cancelled classes"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final c = list[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: c.newClassDateTime == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Class: ${c.className}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${c.catStatus}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10.fSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Date: ${DateFormat('d MMM yyyy').format(c.classDateTime!)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12.fSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    /// Left: Request Pending
                    Expanded(
                      child: _statusBlock(
                        isShowStatus: true,
                        title: "${c.catStatus}",
                        titleColor: Colors.red,
                        className: "Class: ${c.className}",
                        date: c.classDateTime == null
                            ? ""
                            : "Date: ${DateFormat('d MMM yyyy').format(c.classDateTime!)}", // e.g. Mon, Oct 26
                        time: "Time: ${c.time}", // e.g. 6:00 PM
                      ),
                    ),

                    /// Arrow
                    Container(
                      margin: EdgeInsets.only(right: 15.w),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),

                    /// Right: New Booking
                    Expanded(
                      child: _statusBlock(
                        isShowStatus: false,
                        title: "",
                        titleColor: Colors.transparent,
                        className: "Class: ${c.className}",
                        date: c.newClassDateTime == null
                            ? ""
                            : "Date: ${DateFormat('d MMM yyyy').format(c.newClassDateTime!)}", // e.g. Mon, Oct 26
                        time: c.newClassDateTime == null
                            ? ""
                            : "Time: ${DateFormat('h:mm a').format(c.newClassDateTime!)}",
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _statusBlock({
    required bool isShowStatus,
    required String title,
    required Color titleColor,
    required String className,
    required String date,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isShowStatus
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: titleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 10.fSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '',
                  style: TextStyle(
                    color: Colors.transparent,
                    fontSize: 10.fSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        const SizedBox(height: 6),
        Text(
          "$className",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          "$date",
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Text(
          "$time",
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}
