import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
// import 'package:melodica_app_new/melodica_flutter_main.dart';
import 'package:melodica_app_new/providers/appstate_provider.dart';
import 'package:melodica_app_new/providers/notification_provider.dart';
// import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
// import 'package:melodica_app_new/services/deep_links.dart';
// import 'package:melodica_app_new/views/onboarding/onboarding_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> scaleAnim;
  late final Animation<double> fadeAnim;
  // final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().init(context);
    });
    _controller.forward();
    Future.microtask(() async {
      final provider = Provider.of<AppstateProvider>(context, listen: false);
      // final authProvider = Provider.of<AuthProviders>(context, listen: false);
      final cusprovider = Provider.of<CustomerController>(
        context,
        listen: false,
      );

      await provider.initAppState();
      await cusprovider.fetchCustomerData();
      context.read<NotificationProvider>().fetchNotifications();
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (mounted) {
          if (provider.isFirstLaunch) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.onboarding,
              (routes) => false,
            );
            return;
          } else if (user == null) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a very similar yellow background and centered branding with animated subtitle
    return Scaffold(
      body: Stack(
        children: [
          Container(color: AppColors.primary),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/svg/splash_icon.svg'),
                // Text(
                //   'Melodica',
                //   style: TextStyle(
                //     fontFamily: 'Georgia',
                //     fontSize: 48,
                //     fontWeight: FontWeight.w700,
                //     color: Colors.black87,
                //   ),
                // ),
                // const SizedBox(height: 16),
                // AnimatedBuilder(
                //   animation: _controller,
                //   builder: (context, child) {
                //     return Opacity(
                //       opacity: fadeAnim.value,
                //       child: Transform.scale(
                //         scale: scaleAnim.value,
                //         child: child,
                //       ),
                //     );
                //   },
                //   child: const Text(
                //     'Music & Dance Academy',
                //     style: TextStyle(
                //       fontSize: 18,
                //       fontWeight: FontWeight.w500,
                //       color: Colors.black87,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
