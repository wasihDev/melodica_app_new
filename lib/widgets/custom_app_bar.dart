import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/dashboard_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_student_item_widget.dart';
import 'package:melodica_app_new/views/dashboard/notification/notification_screen.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:showcaseview/showcaseview.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;

  const CustomAppBar({super.key, this.height = kToolbarHeight});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomAppBarState extends State<CustomAppBar> {
  Future<void> _loadHomeData() async {
    // final context = context;
    final provider = Provider.of<UserprofileProvider>(context, listen: false);
    final schedule = Provider.of<ScheduleProvider>(context, listen: false);
    final cusprovider = Provider.of<CustomerController>(context, listen: false);
    final package = Provider.of<PackageProvider>(context, listen: false);

    print('cusprovider.isShowData ${cusprovider.isShowData}');
    await package.fetchPackages(context);
    await context.read<ServicesProvider>().fetchDancePackages();
    await cusprovider.getDisplayDance(
      cusprovider.selectedBranch ?? cusprovider.customer!.territoryid,
    );
    await provider.loadImageFromPrefs();
    await schedule.fetchSchedule(context);
    context.read<NotificationProvider>().fetchNotifications();
  }

  Widget _studentDropdown(BuildContext context, Widget child) {
    final ctrl = context.read<CustomerController>();
    final Schedulectrl = context.read<ScheduleProvider>();

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.zero,

      itemBuilder: (_) => [
        ...ctrl.students.map(
          (student) => CustomStudentItem(
            student: student,
            value: student.mbId.toString(),
          ),
        ),
        const PopupMenuDivider(),
        AddStudentItem(value: 'add_new'),
      ],

      onSelected: (value) async {
        print('callue $value');
        if (value == 'add_new') {
          Navigator.pushNamed(context, AppRoutes.newStudent);
          return;
        }

        final student = ctrl.students.firstWhere(
          (e) => e.mbId.toString() == value,
        );
        ctrl.selectStudent(student);
        // call here upcoming classes
        await Schedulectrl.fetchSchedule(context);
        await _loadHomeData();

        setState(() {});
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // foregroundColor: Colors.white,
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,

      title: _studentDropdown(
        context,

        Row(
          children: [
            /// PROFILE IMAGE
            Consumer<UserprofileProvider>(
              builder: (_, provider, __) {
                return CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  backgroundImage: provider.uint8list == null
                      ? const NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/219/219983.png',
                        )
                      : MemoryImage(provider.uint8list!),
                );
              },
            ),

            const SizedBox(width: 12),

            /// STUDENT NAME + ID
            Consumer<CustomerController>(
              builder: (_, provider, __) {
                final student = provider.selectedStudent;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 180.w,
                          color: Colors.transparent,
                          child: Text(
                            student?.fullName ?? "loading..",
                            // provider.customer!.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),

                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                    Text(
                      "${student?.mbId ?? ''}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                );
                // _studentDropdown(
                //   context,

                // );
              },
            ),
          ],
        ),
      ),

      actions: [
        Consumer<NotificationProvider>(
          builder: (context, pro, child) {
            return Showcase(
              key: notificationKey,
              title: "Notifications",
              description:
                  "Receive academy announcements, class rescheduling, and reminders.",
              onBarrierClick: () {
                ShowCaseWidget.of(context).next();
              },
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 35.h,
                  width: 35.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: badges.Badge(
                    showBadge: pro.unread.length == 0 ? false : true,
                    badgeContent: Text(
                      pro.unread.length.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: const Color.fromARGB(255, 255, 188, 5),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(width: 16),
      ],
    );
  }
}

// --- Custom PopupMenuEntry for "Add New Students" Row ---
class AddStudentItem extends PopupMenuItem<String> {
  AddStudentItem({super.key, required String value})
    : super(
        value: value,
        child: Row(
          children: const [
            Icon(Icons.add, size: 18),
            SizedBox(width: 10),
            Text('Add New Student'),
          ],
        ),
      );
}
