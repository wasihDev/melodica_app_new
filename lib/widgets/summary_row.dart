import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import '../constants/app_colors.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final FontWeight labelWeight;
  final FontWeight valueWeight;
  final double fontSize;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.darkText,
    this.labelWeight = FontWeight.normal,
    this.valueWeight = FontWeight.normal,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.darkText,
              fontWeight: labelWeight,
            ),
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/svg/dirham.svg',
                color: valueColor,
                height: 12.h,
                width: 12.w,
              ),
              SizedBox(width: 5.w),
              Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: fontSize,
                  color: valueColor,
                  fontWeight: valueWeight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SummaryRow1 extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final FontWeight labelWeight;
  final FontWeight valueWeight;
  final double fontSize;

  const SummaryRow1({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.darkText,
    this.labelWeight = FontWeight.normal,
    this.valueWeight = FontWeight.normal,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.darkText,
              fontWeight: labelWeight,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: fontSize,
                  color: valueColor,
                  fontWeight: valueWeight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
