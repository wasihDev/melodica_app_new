import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melodica_app_new/constants/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // canvasColor: AppColors.background,
    // primarySwatch: MaterialColor(Color(0xFF2F62FF)),
    scaffoldBackgroundColor: AppColors.background,
    listTileTheme: const ListTileThemeData(tileColor: Colors.white),
    // dividerColor: Colors.grey[300],
    dividerTheme: DividerThemeData(color: Colors.grey[300]),
    // textTheme: TextTheme(displayLarge: ),
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // ✅ Transparent for immersive look
        statusBarIconBrightness:
            Brightness.dark, // ✅ Dark icons on light background
        statusBarBrightness: Brightness.light, // ✅ Light status bar background
        systemNavigationBarColor: AppColors.background, // ✅ Match scaffold
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      backgroundColor: AppColors.background,
    ),
    colorScheme: const ColorScheme.light(),
    fontFamily: 'Poppins',

    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    // canvasColor: AppColors.darkbackground,
    brightness: Brightness.dark,
    listTileTheme: const ListTileThemeData(
      tileColor: Color.fromARGB(255, 18, 18, 18),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey[800]),
    // dividerColor:,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // ✅ Transparent for immersive look
        statusBarIconBrightness:
            Brightness.light, // ✅ Light icons on dark background
        statusBarBrightness: Brightness.dark, // ✅ Dark status bar background
        systemNavigationBarColor: Colors.grey[900], // ✅ Match scaffold
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    primaryTextTheme: const TextTheme(),
    colorScheme: const ColorScheme.dark(),
    fontFamily: 'Poppins',
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: const OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: const OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
