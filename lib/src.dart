import 'package:flutter/material.dart';
import 'package:melodica_app_new/providers/appstate_provider.dart';
import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/providers/bottom_nav_provider.dart';
import 'package:melodica_app_new/providers/country_code_provider.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
import 'package:melodica_app_new/providers/onboarding_provider.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CountryCodeProvider>(
          create: (_) => CountryCodeProvider()..fetch(),
        ),
        ChangeNotifierProvider<CustomerController>(
          create: (_) {
            final provider = CustomerController();
            provider.fetchCustomerData();
            return provider;
          },
        ),
        ChangeNotifierProvider<ServicesProvider>(
          create: (context) => ServicesProvider(
            customerController: context.read<CustomerController>(),
          ),
        ),
        ChangeNotifierProvider<ScheduleProvider>(
          create: (context) => ScheduleProvider(
            servicesProvider: context.read<ServicesProvider>(),
            customerController: context.read<CustomerController>(),
          ),
        ),
        ChangeNotifierProvider<PackageProvider>(
          create: (context) => PackageProvider(
            customerController: context.read<CustomerController>(),
            servicesProvider: context.read<ServicesProvider>(),
            scheduleProvider: context.read<ScheduleProvider>(),
          ),
        ),
        ChangeNotifierProvider<OnboardingProvider>(
          create: (_) => OnboardingProvider(),
        ),
        ChangeNotifierProvider<AppstateProvider>(
          create: (_) => AppstateProvider(),
        ),
        ChangeNotifierProvider<AuthProviders>(create: (_) => AuthProviders()),
        ChangeNotifierProvider<BottomNavProvider>(
          create: (_) => BottomNavProvider(),
        ),

        ChangeNotifierProvider<NotificationProvider>(
          create: (context) => NotificationProvider(
            customerController: context.read<CustomerController>(),
          ),
        ),

        ChangeNotifierProvider<UserprofileProvider>(
          create: (_) => UserprofileProvider(),
        ),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return ShowCaseWidget(
            builder: (context) => MaterialApp(
              title: 'Melodica App',
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              // Theme,
              theme: ThemeData(
                useMaterial3: true,
                // colorScheme: ColorScheme.fromSwatch(
                //   primarySwatch: Colors.amber,
                // ),
                appBarTheme: const AppBarTheme(
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.white,
                ),

                scaffoldBackgroundColor: Colors.white,
              ),
              // routes
              initialRoute: AppRoutes.splash,
              routes: AppRoutes.routes,
            ),
          );
        },
      ),
    );
  }
}
