import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DateCell extends StatelessWidget {
  final String dayOfWeek;
  final String dayOfMonth;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;

  const DateCell({
    super.key,
    required this.dayOfWeek,
    required this.dayOfMonth,
    required this.isSelected,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    Color containerColor = isSelected ? AppColors.primary : AppColors.white;
    Color textColor = isSelected ? AppColors.darkText : AppColors.darkText;
    Color subTextColor = isSelected
        ? AppColors.darkText
        : AppColors.secondaryText;

    // Override colors for the highlighted state (if not selected)
    if (isHighlighted && !isSelected) {
      textColor = AppColors.darkText; // Keep main text dark
      subTextColor = AppColors.darkText; // Keep sub text dark
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 55,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(8),
          border: isHighlighted && !isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayOfWeek,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayOfMonth,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
