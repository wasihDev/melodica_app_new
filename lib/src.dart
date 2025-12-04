import 'package:flutter/material.dart';
import 'package:melodica_app_new/providers/appstate_provider.dart';
import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/providers/bottom_nav_provider.dart';
import 'package:melodica_app_new/providers/onboarding_provider.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';

import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<OnboardingProvider>(create: (_) => OnboardingProvider()),
        Provider<AppstateProvider>(create: (_) => AppstateProvider()),
        Provider<AuthProviders>(create: (_) => AuthProviders()),
        Provider<BottomNavProvider>(create: (_) => BottomNavProvider()),
        Provider<UserprofileProvider>(create: (_) => UserprofileProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            title: 'Melodica App',
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white,
            ),
            // routes
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
