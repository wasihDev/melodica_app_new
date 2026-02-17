import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';

class CustomWeeklyDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime expiryDate; // 1. Added expiryDate parameter
  final Function(DateTime) onDateSelected;
  final String title;

  const CustomWeeklyDatePicker({
    super.key,
    required this.initialDate,
    required this.title,
    required this.expiryDate, // Pass this from your API data
    required this.onDateSelected,
  });

  @override
  State<CustomWeeklyDatePicker> createState() => _CustomWeeklyDatePickerState();
}

class _CustomWeeklyDatePickerState extends State<CustomWeeklyDatePicker> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;
  bool _isBrowsing = false;
  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate;
    _selectedDate = widget.initialDate;
  }

  // 1. Define the selection limit: Expiry Date + 7 Days
  DateTime get _selectionLimit {
    return widget.expiryDate.add(const Duration(days: 7));
  }

  bool _isDateDisabled(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);

    // Disable if before today OR after the 7-day extension limit
    return d.isBefore(today) || d.isAfter(_selectionLimit);
  }

  void _changeWeek(int weeks) {
    DateTime newFocus = _focusedDate.add(Duration(days: weeks * 7));

    // Optional: Prevent navigating too far past the limit (e.g., max 1 week past limit)
    if (weeks > 0 &&
        newFocus.isAfter(_selectionLimit.add(const Duration(days: 7)))) {
      return;
    }

    setState(() {
      _focusedDate = newFocus;
      // _selectedDate = null;
      _isBrowsing = true;
    });
  }

  // Helper to get the 7 days of the week for the focused date
  List<DateTime> _getWeekDays(DateTime date) {
    // Finding Monday of the current week
    DateTime monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getWeekDays(_focusedDate);
    // Accessing your provider to find available dates
    final scheduleProvider = context.read<ScheduleProvider>();

    return Container(
      padding: EdgeInsets.all(16.adaptSize),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header: Select Date
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.title,
                //  'Select Date and Time',
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // 2. Navigation: < Wed, 3 Nov, 2025 >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, size: 20.adaptSize),
                onPressed: () => _changeWeek(-1),
              ),
              Text(
                _isBrowsing
                    ? DateFormat('EEE, d MMM, yyyy').format(_focusedDate)
                    : DateFormat('EEE, d MMM, yyyy').format(_selectedDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 14.fSize),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 20.adaptSize),
                onPressed: () => _changeWeek(1),
              ),
            ],
          ),

          // 3. Days Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              final isSelected = _isSameDay(day, _selectedDate);
              final isDisabled = _isDateDisabled(day);
              final isAvailable = scheduleProvider.availableDates.any(
                (d) => _isSameDay(d, day),
              );
              // final provider= Provider.of<ScheduleProvider>(context,listen: false);
              final isPast = _isPastDate(day); // check if day is past
              return GestureDetector(
                onTap: isDisabled || isPast
                    ? null // disable tap for past days
                    : () {
                        setState(() => _selectedDate = day);
                        _isBrowsing = false;
                        widget.onDateSelected(day);
                      },
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(day).substring(0, 2),
                      style: TextStyle(
                        color: isDisabled || isPast
                            ? Colors.grey
                            : Colors.black, // grey for past
                        fontSize: 14.fSize,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 40.w,
                      height: 45.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color.fromARGB(255, 255, 200, 0)
                            : isAvailable
                            ? const Color(0xFFFBF3D3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 16.fSize,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isPast || isDisabled
                              ? Colors.grey[400]
                              : isSelected || isAvailable
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isPastDate(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);
    return d.isBefore(today); // true if day is before today
  }
}
