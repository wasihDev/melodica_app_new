import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/schedule_model.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/utils/date_format.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:melodica_app_new/views/dashboard/home/package_selection_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/webview_online_store.dart';
import 'package:melodica_app_new/views/dashboard/schedule/reschedule_screen.dart';
import 'package:melodica_app_new/views/dashboard/schedule/widget/dialog_widgets.dart';
import 'package:melodica_app_new/views/profile/packages/packages_screen.dart';
import 'package:melodica_app_new/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    print('calling init');
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      await _loadHomeData();
      setState(() {});
    });
  }

  Future<void> _loadHomeData() async {
    final provider = Provider.of<UserprofileProvider>(context, listen: false);
    final schedule = Provider.of<ScheduleProvider>(context, listen: false);
    final cusprovider = Provider.of<CustomerController>(context, listen: false);
    print('cusprovider.isShowData ${cusprovider.isShowData}');
    if (cusprovider.isShowData.isEmpty) {
      await cusprovider.fetchCustomerData();
      await cusprovider.getDisplayDance();
      // context.read<NotificationProvider>().fetchNotifications();
      await provider.fetchUserData();
      await provider.loadImageFromPrefs();
      await schedule.fetchSchedule(context);
      await cusprovider.fetchPhoneMeta();
      await cusprovider.upsertCustomer();
      context.read<NotificationProvider>().fetchNotifications();
    } else {
      context.read<NotificationProvider>().fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: CustomAppBar(),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Main Content
              Column(
                children: [
                  Divider(),
                  SizedBox(height: 16.h),
                  // Welcome Banner
                  // Container(
                  //   height: 96.h,
                  //   margin: const EdgeInsets.symmetric(horizontal: 16),
                  //   padding: const EdgeInsets.symmetric(horizontal: 10),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.primary,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   alignment: Alignment.center,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const Text(
                  //             'Welcome',
                  //             style: TextStyle(
                  //               fontSize: 18,
                  //               fontWeight: FontWeight.bold,
                  //               color: Colors.black,
                  //             ),
                  //           ),
                  //           const SizedBox(height: 4),
                  //           Text(
                  //             'Keep Shine in the Worlds',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Colors.black.withOpacity(0.8),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       Stack(
                  //         children: [
                  //           const Text('🎹', style: TextStyle(fontSize: 60)),
                  //           Positioned(
                  //             right: -10,
                  //             top: -10,
                  //             child: Text('✨', style: TextStyle(fontSize: 20)),
                  //           ),
                  //           Positioned(
                  //             right: 20,
                  //             top: 10,
                  //             child: Text('✨', style: TextStyle(fontSize: 16)),
                  //           ),
                  //           Positioned(
                  //             right: -5,
                  //             bottom: 15,
                  //             child: Text('✨', style: TextStyle(fontSize: 14)),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 25.h),

                  // Category Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryCard(
                          'assets/svg/music_class.svg',
                          'Add Music',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PackageSelectionScreen(
                                  isShowdanceTab: false,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),

                        Consumer<CustomerController>(
                          builder: (context, crtl, child) {
                            return Expanded(
                              child: Column(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: crtl.display
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PackageSelectionScreen(
                                                      isShowdanceTab: true,
                                                    ),
                                              ),
                                            );
                                          }
                                        : () {
                                            SnackbarUtils.showInfo(
                                              context,
                                              "There are currently no dance packages available for this branch.Feel free to enquire about packages at our other branches.",
                                            );
                                          },
                                    child: SvgPicture.asset(
                                      'assets/svg/dance_class.svg',
                                      color: crtl.display
                                          ? null
                                          : Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Dance',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.fSize,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildCategoryCard(
                          'assets/svg/packages.svg',
                          'My Packages',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PackageListScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildCategoryCard(
                          'assets/svg/online_store.svg',
                          'Online Store',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WebViewPage(
                                  url: 'https://melodicamusicstore.com/',
                                  title: 'Online Store',
                                ),
                              ),
                            );
                          },
                        ),
                        // _buildCategoryCard(
                        //   'assets/svg/online_store.svg',
                        //   'Online Store',
                        //   onTap: () async {
                        //     if (!await launchUrl(
                        //       Uri.parse('https://melodicamusicstore.com/'),
                        //       mode: LaunchMode.externalApplication,
                        //     )) {
                        //       throw Exception('Could not launch');
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.only(left: 12, right: 0, top: 15),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xffF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xffE2E2E2)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  // final ctrl = context.read<CustomerController>();
                                  Consumer<CustomerController>(
                                    builder: (context, ctrl, child) {
                                      return Text(
                                        'Upcoming Classes for ${ctrl.selectedStudent?.firstName}',
                                        style: TextStyle(
                                          fontSize: 16.fSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    },
                                  ),
                                  // Text('Today Scheduled Classes'),
                                ],
                              ),
                              // IconButton(
                              //   onPressed: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => ScheduleScreen(),
                              //       ),
                              //     );
                              //   },
                              //   icon: Icon(Icons.arrow_forward),
                              // ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Consumer<ScheduleProvider>(
                            builder: (context, provider, child) {
                              if (provider.isLoading) {
                                return Container(
                                  height: 320.h,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                height: 320.h,
                                color: Colors.transparent,
                                child: ListView.separated(
                                  itemCount: provider.upcomingSchedules.length,
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 8.h),
                                  itemBuilder: (context, index) {
                                    final item =
                                        provider.upcomingSchedules[index];
                                    return Container(
                                      margin: EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          showAppointmentBottomSheet(
                                            context,
                                            item,
                                          );
                                        },
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 12,
                                        ),
                                        visualDensity: VisualDensity(
                                          vertical: 2,
                                        ),
                                        tileColor: Colors.white,
                                        leading: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${item.bookingDay.isEmpty ? '' : item.bookingDay.substring(0, 3)}',
                                            ),
                                            Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: AppColors.primary,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  item.day.toString(),
                                                  style: TextStyle(
                                                    fontSize: 14.fSize,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text('${item.monthShort}'),
                                          ],
                                        ),
                                        title: Text(
                                          item.subject,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.fSize,
                                          ),
                                        ),
                                        subtitle: Text(item.bookingRoom),
                                        trailing: Text(
                                          item.time.startsWith('0')
                                              ? item.time.substring(1)
                                              : item.time,
                                          // item.time.toString(),
                                          style: TextStyle(
                                            fontSize: 12.fSize,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
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
      ),
    );
  }

  void showAppointmentBottomSheet(BuildContext context, ScheduleModel s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
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
                  final expiryDate = DateTime.parse(s.PackageExpiry);

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
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFFFF7EC), // Light cream background
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: const [
              //       Text(
              //         'PLEASE NOTE',
              //         style: TextStyle(
              //           color: Color(0xFFE67E22), // Orange text
              //           fontWeight: FontWeight.bold,
              //           fontSize: 14,
              //         ),
              //       ),
              //       SizedBox(height: 8),
              //       Text(
              //         'Reschedule before the 9th (Dynamic) to avoid using your cancellation.',
              //         style: TextStyle(color: Colors.grey, fontSize: 13),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ///call get availablity api

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RescheduleScreen(s: s)),
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
                height: 50,
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
        );
      },
    );
  }

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

  Widget _buildCategoryCard(
    String emoji,
    String label, {
    required void Function()? onTap,
  }) {
    return Expanded(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: SvgPicture.asset(emoji),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.fSize,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void showLateNoticeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
}
