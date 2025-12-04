import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
import 'package:melodica_app_new/widgets/date_cell.dart';

class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key});

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  int _selectedDay = 5; // Day 5 (Wednesday) is selected
  String _startTime = '12:30 AM';
  String _endTime = '1:00 PM';

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

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.darkText,
              onSurface: AppColors.darkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final timeString = picked.format(context);
        if (isStart) {
          _startTime = timeString;
        } else {
          _endTime = timeString;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Reschedule',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.notifications_outlined, color: AppColors.primary),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Basics of Piano',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.darkText,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Class of Ms Sara',
              style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
            ),
          ),
          const SizedBox(height: 24),

          // Select Date Dropdown (Placeholder)
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
                  isHighlighted: date['dayOfMonth'] == '5',
                  onTap: () {
                    setState(() {
                      _selectedDay = int.parse(date['dayOfMonth']!);
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Time Slot Picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGrey, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _selectTime(context, true),
                    child: Text(
                      _startTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const Text(
                    '-',
                    style: TextStyle(fontSize: 16, color: AppColors.darkText),
                  ),
                  GestureDetector(
                    onTap: () => _selectTime(context, false),
                    child: Text(
                      _endTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const Icon(Icons.schedule, color: AppColors.secondaryText),
                ],
              ),
            ),
          ),

          // Spacer to push the button down
          const Spacer(),

          // Fixed Bottom Button
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 24,
              top: 12,
            ),
            child: PrimaryButton(
              text: 'Schedule Now',
              onPressed: () {
                print(
                  'Reschedule pressed for $_startTime to $_endTime on day $_selectedDay',
                );
                // Handle rescheduling logic
              },
            ),
          ),
        ],
      ),
    );
  }
}
