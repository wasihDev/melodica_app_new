import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/home/faq/help_center.dart';
import 'package:melodica_app_new/views/dashboard/home/home_screen.dart';
import 'package:melodica_app_new/views/dashboard/schedule/schedule_screen.dart';
import 'package:melodica_app_new/views/profile/profile_screen.dart';
import 'package:upgrader/upgrader.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ScheduleScreen(),
    HelpCenter(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: Platform.isIOS
          ? UpgradeDialogStyle.cupertino
          : UpgradeDialogStyle.material,
      showIgnore: false,
      shouldPopScope: () => false,
      showLater: false,
      upgrader: Upgrader(countryCode: "AE"),
      child: Scaffold(
        body: _pages[_selectedIndex],
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 20.0.h),
          child: Container(
            height: 80.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
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
                    icon: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1
                            ? const Color(0xFFFFC107)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgPicture.asset('assets/svg/schedule.svg'),
                    ),
                    label: 'Schedule',
                  ),

                  BottomNavigationBarItem(
                    icon: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 2
                            ? const Color(0xFFFFC107)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.headset_outlined, color: Colors.black),
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
      ),
    );
  }
}
