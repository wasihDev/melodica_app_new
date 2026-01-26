import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  bool isShowLogout = false;
  AppBarWidget({super.key, required this.title, required this.isShowLogout});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserprofileProvider>(
      builder: (context, provider, child) {
        return AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            isShowLogout
                ? IconButton(
                    icon: SvgPicture.asset(
                      'assets/svg/exit.svg',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {
                      final provider = Provider.of<AuthProviders>(
                        context,
                        listen: false,
                      );
                      provider.logout(context);
                      // Handle forward action
                    },
                  )
                : SizedBox(),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size(10.h, 50.w);
}
