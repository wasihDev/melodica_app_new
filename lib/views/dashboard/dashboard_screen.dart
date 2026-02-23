import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/constants/global_variables.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/services/upgrade_custom_dialog.dart';
import 'package:melodica_app_new/views/dashboard/home/faq/help_center.dart';
import 'package:melodica_app_new/views/dashboard/home/home_screen.dart';
import 'package:melodica_app_new/views/dashboard/schedule/schedule_screen.dart';
import 'package:melodica_app_new/views/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:nb_utils/nb_utils.dart';

final GlobalKey bookClassKey = GlobalKey();
final GlobalKey scheduleKey = GlobalKey();
final GlobalKey onlinestore = GlobalKey();
final GlobalKey notificationKey = GlobalKey();
final GlobalKey packageKey = GlobalKey();
final GlobalKey dancekey = GlobalKey();
final GlobalKey selectStudent = GlobalKey();

// final GlobalKey dancekey=GlobalKey();
// final GlobalKey dancekey=GlobalKey();
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    // print('calling init');
    // Future.microtask(() async {
    //   await _loadHomeData();
    // });

    WidgetsBinding.instance.addPostFrameCallback((val) async {
      final cusprovider = Provider.of<CustomerController>(
        context,
        listen: false,
      );

      if (cusprovider.isCustomerRegistered) {
        _checkFirstLaunch();
      }
      await _loadHomeData();
    });
  }

  Future<void> _loadHomeData() async {
    // final context = context;
    final provider = Provider.of<UserprofileProvider>(context, listen: false);
    final schedule = Provider.of<ScheduleProvider>(context, listen: false);
    final cusprovider = Provider.of<CustomerController>(context, listen: false);
    final package = Provider.of<PackageProvider>(context, listen: false);
    print(
      'cusprovider.isCustomerRegistered ${cusprovider.isCustomerRegistered}',
    );
    print('cusprovider.isShowData ${cusprovider.isShowData}');
    if (openedFromNotification) {
      openedFromNotification = false;
      // this is for notificaiton navigation
      return; // ❌ Do not navigate
    }
    UpdateService.checkVersion(context);

    if (cusprovider.isShowData.isEmpty) {
      await provider.fetchUserData();
      await cusprovider.fetchCustomerData();
      await cusprovider.upsertCustomer();
      if (cusprovider.isCustomerRegistered) {
        _checkFirstLaunch();
      }
      await package.fetchPackages(context);
      await context.read<ServicesProvider>().fetchDancePackages();
      await cusprovider.getDisplayDance(
        cusprovider.selectedBranch ?? cusprovider.customer!.territoryid,
      );
      await provider.loadImageFromPrefs();
      await schedule.fetchSchedule(context);
      await cusprovider.fetchPhoneMeta();

      context.read<NotificationProvider>().fetchNotifications();
    } else {
      context.read<NotificationProvider>().fetchNotifications();
    }
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('melodica_showcases') ?? true;

    if (isFirstTime) {
      ShowcaseView.register(
        autoPlay: true,
        hideFloatingActionWidgetForShowcase: [scheduleKey],
        globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
          left: 16,
          bottom: 16,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => ShowcaseView.get().dismiss(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffEE5366),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ),
        onStart: (index, key) {
          log('onStart: $index, $key');
        },
        onComplete: (index, key) {
          log('onComplete: $index, $key');
          if (index == 4) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle.light.copyWith(
                statusBarIconBrightness: Brightness.dark,
                statusBarColor: Colors.white,
              ),
            );
          }
        },
        blurValue: 1,
        autoPlayDelay: const Duration(seconds: 3),
        globalTooltipActionConfig: const TooltipActionConfig(
          position: TooltipActionPosition.inside,
          alignment: MainAxisAlignment.spaceBetween,
          actionGap: 20,
        ),
        globalTooltipActions: [
          // Here we don't need previous action for the first showcase widget
          // so we hide this action for the first showcase widget
          TooltipActionButton(
            type: TooltipDefaultActionType.previous,
            textStyle: const TextStyle(color: Colors.white),
            hideActionWidgetForShowcase: [selectStudent],
          ),
          // Here we don't need next action for the last showcase widget so we
          // hide this action for the last showcase widget
          TooltipActionButton(
            type: TooltipDefaultActionType.next,
            textStyle: const TextStyle(color: Colors.white),
            hideActionWidgetForShowcase: [scheduleKey],
          ),
        ],
        onDismiss: (key) {
          debugPrint('Dismissed at $key');
        },
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowcaseView.get().startShowCase([
          selectStudent,
          notificationKey,
          bookClassKey,
          dancekey,
          packageKey,
          onlinestore,
          scheduleKey,
        ]),
      );
      // ShowCaseWidget.of(navigatorKey.currentContext!).startShowCase([
      // selectStudent,
      // notificationKey,
      // bookClassKey,
      // dancekey,
      // packageKey,
      // onlinestore,
      // scheduleKey,
      // ]);

      prefs.setBool('melodica_showcases', false);
    }
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
    super.dispose();
  }

  final List<Widget> _pages = [
    HomeScreen(),
    ScheduleScreen(),
    HelpCenter(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) {
        return Scaffold(
          body: _pages[_selectedIndex],
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: SafeArea(
            bottom: Platform.isIOS ? false : true,
            child: Container(
              height: 90.h,
              margin: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: Platform.isIOS ? 10 : 10,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xffE2E2E2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Color(0xffF7F7F7),
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.grey,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  elevation: 0,
                  selectedLabelStyle: TextStyle(fontSize: 14.fSize),
                  unselectedLabelStyle: TextStyle(fontSize: 12.fSize),
                  items: [
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 0
                              ? const Color(0xFFFFC107)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SvgPicture.asset('assets/svg/home.svg'),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Showcase(
                        key: scheduleKey,
                        title: "Schedule",
                        description:
                            "View and manage your classes — reschedule or cancel with ease",
                        onBarrierClick: () {
                          ShowCaseWidget.of(context).next();
                        },
                        tooltipActionConfig: const TooltipActionConfig(
                          alignment: MainAxisAlignment.spaceBetween,
                          gapBetweenContentAndAction: 10,
                          position: TooltipActionPosition.outside,
                        ),

                        titleAlignment: Alignment.topLeft,
                        titleTextStyle: TextStyle(
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.w700,
                        ),

                        descTextStyle: TextStyle(color: Colors.grey[700]),
                        tooltipActions: const [
                          TooltipActionButton(
                            backgroundColor: Colors.transparent,
                            type: TooltipDefaultActionType.previous,
                            padding: EdgeInsets.symmetric(vertical: 4),
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          TooltipActionButton(
                            type: TooltipDefaultActionType.next,
                            backgroundColor: AppColors.primary,
                            textStyle: TextStyle(color: Colors.black),
                          ),
                        ],
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedIndex == 1
                                ? const Color(0xFFFFC107)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SvgPicture.asset('assets/svg/schedule.svg'),
                        ),
                      ),

                      label: 'Schedule',
                    ),

                    BottomNavigationBarItem(
                      icon: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 2
                              ? const Color(0xFFFFC107)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.headset_outlined,
                          color: Colors.black,
                        ),
                        // SvgPicture.asset('assets/svg/progress.svg'),
                      ),
                      label: 'Help',
                    ),

                    BottomNavigationBarItem(
                      icon: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 3
                              ? const Color(0xFFFFC107)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SvgPicture.asset('assets/svg/profile.svg'),
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
