import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/schedule/reschedule_screen.dart';
import 'package:melodica_app_new/widgets/appointment_card.dart';
import 'package:melodica_app_new/widgets/custom_app_bar.dart';
import 'package:melodica_app_new/widgets/date_cell.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 5; // Day 5 (Wednesday) is selected
  DateTime _currentWeekStart = DateTime(2025, 11, 3); // Start of the week shown

  // Sample data for the week shown in the screenshot
  final List<Map<String, String>> _weekDates = [
    {'dayOfWeek': 'Mo', 'dayOfMonth': '3'},
    {'dayOfWeek': 'Tu', 'dayOfMonth': '4'},
    {'dayOfWeek': 'We', 'dayOfMonth': '5'},
    {'dayOfWeek': 'Th', 'dayOfMonth': '6'},
    {'dayOfWeek': 'Fr', 'dayOfMonth': '7'},
    {'dayOfWeek': 'Sa', 'dayOfMonth': '8'},
    {'dayOfWeek': 'Su', 'dayOfMonth': '9'},
  ];

  // Sample appointments
  final List<Map<String, dynamic>> _appointments = [
    {'dayHeader': 'Wed, 3 Nov, 2025'},
    {
      'dayOfWeek': 'Wed',
      'dayOfMonth': '5',
      'month': 'Nov',
      'courseName': 'Basics of Piano',
      'teacher': 'Class of Ms Sara',
      'time': '4:00PM',
      'date': '5',
    },
    {
      'dayOfWeek': 'Wed',
      'dayOfMonth': '5',
      'month': 'Nov',
      'courseName': 'Basics of Piano',
      'teacher': 'Class of Ms Sara',
      'time': '4:00PM',
      'date': '5',
    },
    {
      'dayOfWeek': 'Wed',
      'dayOfMonth': '5',
      'month': 'Nov',
      'courseName': 'Basics of Piano',
      'teacher': 'Class of Ms Sara',
      'time': '4:00PM',
      'date': '5',
      'isSelected': true,
    },
    {'dayHeader': 'Thur, 4...'},
    {
      'dayOfWeek': 'Thu',
      'dayOfMonth': '6',
      'month': 'Nov',
      'courseName': 'Basics of Piano',
      'teacher': 'Class of Ms Sara',
      'time': '4:00PM',
      'date': '6',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(),
      // appBar: AppBar(
      //   backgroundColor: AppColors.white,
      //   elevation: 0,
      //   leading:
      //       const SizedBox.shrink(), // No back button needed on the main schedule tab
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       // Student Selector
      //       Row(
      //         children: [
      //           const CircleAvatar(
      //             radius: 20,
      //             // Placeholder for student avatar image
      //             backgroundColor: AppColors.lightGrey,
      //             child: Icon(
      //               Icons.person,
      //               color: AppColors.darkText,
      //               size: 24,
      //             ),
      //           ),
      //           const SizedBox(width: 8),
      //           Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: const [
      //               Text(
      //                 'Tonald Drump',
      //                 style: TextStyle(
      //                   fontWeight: FontWeight.bold,
      //                   fontSize: 16,
      //                   color: AppColors.darkText,
      //                 ),
      //               ),
      //               Text(
      //                 'ID: 000123',
      //                 style: TextStyle(
      //                   fontSize: 12,
      //                   color: AppColors.secondaryText,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //       // Bell Icon
      //       const Icon(Icons.notifications_outlined, color: AppColors.primary),
      //     ],
      //   ),
      // ),
      body: Column(
        children: [
          // Select Date Dropdown (Placeholder)
          Divider(),
          SizedBox(height: 16.h),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Select Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.darkText,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColors.darkText),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Date Picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: AppColors.secondaryText,
                ),

                // Week Label
                Text(
                  'Wed, 3 Nov, 2025',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _weekDates.map((date) {
                return DateCell(
                  dayOfWeek: date['dayOfWeek']!,
                  dayOfMonth: date['dayOfMonth']!,
                  isSelected: date['dayOfMonth'] == _selectedDay.toString(),
                  isHighlighted: date['dayOfMonth'] == '5', // Highlight day 5
                  onTap: () {
                    setState(() {
                      _selectedDay = int.parse(date['dayOfMonth']!);
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Appointment List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final item = _appointments[index];
                if (item.containsKey('dayHeader')) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(
                      item['dayHeader'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.darkText,
                      ),
                    ),
                  );
                } else {
                  return AppointmentCard(
                    dayOfWeek: item['dayOfWeek'],
                    dayOfMonth: item['dayOfMonth'],
                    month: item['month'],
                    courseName: item['courseName'],
                    teacher: item['teacher'],
                    time: item['time'],
                    isSelected:
                        item['date'] == _selectedDay.toString() &&
                        item['isSelected'] ==
                            true, // Selects the specific card if it matches the selected day
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RescheduleScreen(),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),

      // --- Bottom Navigation Bar ---
    );
  }
}
