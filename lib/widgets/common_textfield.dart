import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';

// ignore: must_be_immutable
class CommonTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  bool obscureText;
  final bool isShowSuffix;
  final Function(String)? onChanged;
  final String? helperText;
  final String? labelText;
  final int? maxLines;
  final bool hasError;
  final Widget? wigdet;
  final Widget? suffixWigdet;
  final IconData? passwordHideIcon;
  final IconData? passwordShowIcon;
  final TextInputAction? textInputAction;
  final Color? textColor;
  final Color? accentColor;
  final bool? enabled;
  final String? heading;
  final String? errorTitle;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  void Function()? onEditingComplete;
  CommonTextField({
    Key? key,
    this.enabled,
    required this.controller,
    required this.validator,
    this.isShowSuffix = false,
    this.errorTitle,
    this.onEditingComplete,
    this.hintText,
    this.heading,
    this.keyboardType,
    this.obscureText = false,
    this.suffixWigdet,
    this.onChanged,
    this.helperText,
    this.labelText,
    this.hasError = false,
    this.wigdet,
    this.passwordHideIcon,
    this.passwordShowIcon,
    this.textInputAction,
    this.textColor,
    this.maxLines = 1,
    this.inputFormatters,
    this.accentColor,
  }) : super(key: key);

  @override
  _CommonTextFieldState createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  // bool _isObscure = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themes = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.heading ?? "", style: TextStyle(fontSize: 16.h)),
        SizedBox(height: 8.h),
        TextFormField(
          enabled: widget.enabled,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onEditingComplete: widget.onEditingComplete,
          maxLines: !widget.obscureText ? widget.maxLines : 1,
          inputFormatters: widget.inputFormatters,
          style: TextStyle(
            color: themes ? Colors.white : Colors.black,
          ), // Set text color
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
            // labelText:
            //     widget.labelText ??
            //     'Default Simple TextField', // Use confirmation text as label if provided, else use default label text
            // labelStyle: TextStyle(
            //   color: widget.accentColor ?? Colors.black,
            // ), // Set accent color
            helperText: widget.helperText,
            prefixIcon: widget.wigdet != null
                ? widget
                      .wigdet // Set accent color for prefix icon
                : null,
            suffixIcon: widget.isShowSuffix
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        widget.obscureText = !widget.obscureText;
                      });
                    },
                    icon: Icon(
                      widget.obscureText
                          ? widget.passwordShowIcon ?? Icons.visibility
                          : widget.passwordHideIcon ?? Icons.visibility_off,
                    ),
                    color: AppColors.textSecondary,
                  )
                : widget.suffixWigdet,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.23.adaptSize),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.23.adaptSize),
              borderSide: const BorderSide(
                color: AppColors.textSecondary,
                width: 1.4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.23.adaptSize),
              borderSide: const BorderSide(
                color: AppColors.textSecondary,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.23.adaptSize),
              borderSide: const BorderSide(color: Colors.red, width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.23.adaptSize),
              borderSide: const BorderSide(color: Colors.red, width: 1.4),
            ),
            // You can add more customization to the decoration as needed
            // For example, adding icons, labels, etc.
          ),
        ),
      ],
    );
  }
}
