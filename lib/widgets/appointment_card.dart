import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppointmentCard extends StatelessWidget {
  final String dayOfWeek;
  final String dayOfMonth;
  final String month;
  final String courseName;
  final String teacher;
  final String time;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.dayOfWeek,
    required this.dayOfMonth,
    required this.month,
    required this.courseName,
    required this.teacher,
    required this.time,
    this.isToday = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // print('isSelected $isSelected');
    Color cardColor = isSelected
        ? Color.fromARGB(76, 255, 205, 5)
        : AppColors.white;
    // Color borderColor = isToday ? AppColors.primary : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGrey.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Custom Date Icon (Leading Column)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayOfWeek.isEmpty ? '' : dayOfWeek.substring(0, 3),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.darkText,
                  ),
                ),
                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: Text(
                      dayOfMonth,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ),
                Text(
                  month,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Appointment Details (Main Content)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    teacher,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            // Time
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
