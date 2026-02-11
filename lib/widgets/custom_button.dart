import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/widgets/loading_indicator_widget.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onTap;
  final Widget widget;
  final bool isLoading;
  const CustomButton({
    super.key,
    required this.onTap,
    required this.widget,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.primary,
        // gradient: const LinearGradient(
        //   begin: Alignment.bottomCenter,
        //   end: Alignment.topCenter,
        //   colors: [Color(0xff0241FF), Color(0xff2F62FF)],
        // ),
        borderRadius: BorderRadius.circular(12.adaptSize),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          onTap: isLoading ? null : onTap, // disable tap when loading
          child: Center(
            child: isLoading
                ? const Center(
                    child: LoadingIndicatorWideget(color: AppColors.background),
                  )
                : widget,
          ),
        ),
      ),
    );
  }
}
