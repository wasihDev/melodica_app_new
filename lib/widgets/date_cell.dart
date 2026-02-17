import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';

class CustomWeeklyDatePicker extends StatefulWidget {
  const CustomWeeklyDatePicker({super.key});

  @override
  State<CustomWeeklyDatePicker> createState() => _CustomWeeklyDatePickerState();
}

class _CustomWeeklyDatePickerState extends State<CustomWeeklyDatePicker> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final Color _textColor = const Color(0xFF333333);
  bool _isBrowsing = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 5),
          _buildMonthNavigation(),
          const SizedBox(height: 5),
          _buildWeeklyCalendar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 15.fSize,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        // Icon(Icons.arrow_drop_down, color: _textColor),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => _changeWeek(-1),
        ),
        Text(
          _isBrowsing
              ? DateFormat('EEE, d MMM, yyyy').format(_focusedDate)
              : DateFormat('EEE, d MMM, yyyy').format(_selectedDate),
          style: TextStyle(fontSize: 14.fSize, color: Colors.grey[600]),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward, color: _textColor),
          onPressed: () => _changeWeek(1),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar() {
    final days = _getWeekDays(_focusedDate);
    return Column(
      children: [
        // Day of week labels (Mo, Tu, We...)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((day) {
            return SizedBox(
              width: 40,
              child: Text(
                DateFormat('E').format(day).substring(0, 2),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _textColor),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        // Day numbers (3, 4, 5...)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((day) => _buildDayItem(day)).toList(),
        ),
      ],
    );
  }

  Widget _buildDayItem(DateTime day) {
    final scheduleProvider = context.watch<ScheduleProvider>();

    final isSelected = isSameDay(day, _selectedDate);
    final isAvailable = scheduleProvider.availableDates.any(
      (d) => isSameDay(d, day),
    );

    final isDisabled = isPast(day);

    BoxDecoration? decoration;

    if (isDisabled) {
      decoration = BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.0),
      );
    } else if (isSelected) {
      decoration = BoxDecoration(
        color: const Color.fromARGB(255, 250, 200, 18),
        borderRadius: BorderRadius.circular(12.0),
      );
    } else if (isAvailable) {
      decoration = BoxDecoration(
        color: const Color.fromARGB(255, 251, 231, 150),
        borderRadius: BorderRadius.circular(12.0),
      );
    }

    return InkWell(
      onTap: isDisabled
          ? null // 🚫 disables tap
          : () {
              setState(() {
                _selectedDate = day;
                _isBrowsing = false;
              });
              context.read<ScheduleProvider>().selectDate(day);
            },
      child: Container(
        width: 40,
        height: 50,
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          day.day.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isDisabled
                ? Colors.grey
                : (isAvailable || isSelected ? Colors.black : Colors.grey),
          ),
        ),
      ),
    );
  }

  // Helper to get the 7 days starting from the beginning of the week
  List<DateTime> _getWeekDays(DateTime date) {
    var firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );
  }

  void _changeWeek(int offset) {
    setState(() {
      _focusedDate = _focusedDate.add(Duration(days: offset * 7));
      _isBrowsing = true;
    });
  }

  bool isPast(DateTime day) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final dayOnly = DateTime(day.year, day.month, day.day);

    return dayOnly.isBefore(todayOnly); // only past dates
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
