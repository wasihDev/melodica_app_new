import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';

class AppTextStyles {
  static TextStyle poppinsLight(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).textTheme.bodyLarge?.color,
    fontSize: 15.fSize,
  );

  static TextStyle poppinsRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12.fSize,
  );
  // Black Color fonts
  static TextStyle poppinsMedium(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).textTheme.bodyLarge?.color,
    fontSize: 16.fSize,
  );
  // static TextStyle poppinsMedium14(BuildContext context) => TextStyle(
  //   fontFamily: fontFamily,
  //   fontWeight: FontWeight.w600,
  //   color: Theme.of(context).textTheme.bodyLarge?.color,
  //   fontSize: 14.fSize,
  // );

  static TextStyle poppinsMediumFont(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).textTheme.bodyLarge?.color,
    fontSize: 20.fSize,
  );

  static TextStyle poppinsBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
  );

  static TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 44.fSize,
    color: AppColors.textPrimary,
  );
  static TextStyle poppinsMedium14(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    color: Theme.of(
      context,
    ).textTheme.bodyLarge?.color, //  AppColors.textPrimary,
    fontSize: 13.fSize,
  );
  static TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12.fSize,
    color: AppColors.textSecondary,
  );
  static TextStyle subtitle14 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14.fSize,
    color: AppColors.textSecondary,
  );
  // Primary Color fonts
  static TextStyle subtitlePrimaryColor = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12.fSize,
    color: AppColors.primary,
  );

  static TextStyle subtitleSemiBoldPrimary = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 12.fSize,
    color: AppColors.primary,
  );
  static TextStyle subtitlePrimaryColor16 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16.fSize,
    color: AppColors.primary,
  );
  static TextStyle subtitlePrimaryColor14 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14.fSize,
    color: AppColors.primary,
  );
  static TextStyle subtitlePrimaryColor20 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 20.fSize,
    color: AppColors.primary,
  );
  static TextStyle subtitlePrimaryColor26 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 26.fSize,
    color: AppColors.primary,
  );

  // White Color fonts
  static TextStyle bodyWhiteBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 26.fSize,
    color: AppColors.white,
  );
  static TextStyle bodyWhiteBoldHeading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 28.fSize,
    color: AppColors.white,
  );
  static TextStyle bodyWhiteBold28 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 28.fSize,
    // color: Theme.of(context).textTheme.bodyLarge?.color,
    color: AppColors.white,
  );

  static TextStyle bodyWhiteBold28s = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 28.fSize,
    // color: Theme.of(context).textTheme.bodyLarge?.color,
    color: AppColors.black,
  );
  static TextStyle bodyWhiteBold18 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 18.fSize,
    color: AppColors.white,
  );
  static TextStyle bodyWhiteBold22 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 22.fSize,
    color: AppColors.white,
  );
  static TextStyle bodyWhiteRegular(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 18.fSize,
    color: Theme.of(context).textTheme.bodyLarge?.color,
    // color: AppColors.white,
  );
  static TextStyle bodyWhiteRegulars = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 18.fSize,
    color: AppColors.white,
  );
  static TextStyle bodyWhiteSemiRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15.fSize,
    color: AppColors.white,
  );
  static TextStyle bodyWhiteLight = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15.fSize,
    color: AppColors.white,
  );
  static TextStyle bodyWhiteLight14 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14.23.fSize,
    color: AppColors.white,
  );
  static TextStyle bodyBlackLight14 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14.23.fSize,
    color: AppColors.black,
  );
  static TextStyle subtitleWhiteColor16 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16.fSize,
    color: AppColors.white,
  );
  static TextStyle subtitleWhiteColor12 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12.fSize,
    color: AppColors.white,
  );
}

String fontFamily = 'Poppins';
