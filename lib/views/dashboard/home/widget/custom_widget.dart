import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? child;
  PrimaryButton({
    super.key,
    this.child,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Fixed height for the button
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: child == null
            ? Text(
                text,
                style: TextStyle(
                  fontSize: 18.fSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText, // Text color is dark on yellow
                ),
              )
            : child,
      ),
    );
  }
}

class CustomDropdownField<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<T> items;
  final String Function(T) itemToString;
  final ValueChanged<T?> onChanged;
  final String? hintText;

  const CustomDropdownField({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.itemToString,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text(
            labelText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondaryText),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: hintText != null
                  ? Text(
                      hintText!,
                      style: const TextStyle(color: AppColors.secondaryText),
                    )
                  : null,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.darkText,
              ),
              isExpanded: true,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<T>>((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemToString(item)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? initialValue;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.initialValue,
    this.suffixIcon,
    this.readOnly = false,
    this.controller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text(
            labelText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          // initialValue: initialValue,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            hint: Text(
              initialValue ?? "",
              style: TextStyle(fontSize: 14.fSize, color: Colors.grey[400]),
            ),
            fillColor: AppColors.lightGrey,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              // borderSide: BorderSide(color: AppColors.darkBackground, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.secondaryText, width: .5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(),
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
