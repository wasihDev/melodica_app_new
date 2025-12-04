import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/student_model.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_student_item_widget.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // final String title;
  // final Color backgroundColor;
  // final Color foregroundColor;
  // final bool showBackButton;
  // final Widget?
  // rightAction; // For icons like Exit, Notification, or Forward Arrow
  final double height;

  CustomAppBar({
    super.key,
    // required this.title,
    // this.backgroundColor = AppColors.white,
    // this.foregroundColor = AppColors.darkText,
    // this.showBackButton = true,
    // this.rightAction,
    this.height = kToolbarHeight, // Standard AppBar height
  });

  final List<Student> students = [
    // Note: Replace with your actual image assets or NetworkImage setup
    Student('Tonald Drump', 'ID', 'assets/avatar_1.png'),
    Student('Bul Gates', 'ID: 000124', 'assets/avatar_2.png'),
    Student('Tonald Drump', 'ID: 000128', 'assets/avatar_3.png'),
  ];

  Widget _buildCustomMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      // 1. Define the content of the menu items
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> items = [];

        // Add student items (Custom Widget)
        for (int i = 0; i < students.length; i++) {
          items.add(
            CustomStudentItem(student: students[i], value: students[i].id),
          );
        }

        // Add a divider
        items.add(const PopupMenuDivider(height: 1));

        // Add the 'Add New Students' item (Custom Widget)
        items.add(const AddStudentItem(value: 'add_new'));

        return items;
      },

      // 2. Define what happens when an item is selected
      onSelected: (String value) {
        if (value == 'add_new') {
          print('Navigate to Add New Students screen!');
        } else {
          print('Student selected with ID: $value');
        }
      },

      // 3. Customize the appearance of the button and menu
      offset: const Offset(
        0,
        50,
      ), // Position the menu slightly below the button
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: Colors.white,
      // This is the widget that appears in the AppBar
      child: Icon(Icons.arrow_drop_down, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      // --- Leading Widget: Back Button ---
      // leading: showBackButton
      //     ? IconButton(
      //         icon: Icon(Icons.arrow_back_ios, color: foregroundColor),
      //         onPressed: () {
      //           Navigator.of(context).pop();
      //         },
      //       )
      //     : const SizedBox.shrink(),

      // --- Title ---
      title: Row(
        children: [
          Consumer<UserprofileProvider>(
            builder: (context, provider, child) {
              return Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  backgroundImage: provider.uint8list == null
                      ? const NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/219/219983.png',
                        )
                      : MemoryImage(provider.uint8list!),
                  radius: 22.h,
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Consumer<UserprofileProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        provider.userModel.firstName ?? "...",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCustomMenuButton(context),
                ],
              ),
              Text(
                students[0].id,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,

      // --- Actions Widget: Notification/Exit/Forward Icon ---
      actions: [
        Stack(
          children: [
            const Text('🔔', style: TextStyle(fontSize: 32)),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
