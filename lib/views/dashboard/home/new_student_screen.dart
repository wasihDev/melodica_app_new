import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/views/dashboard/home/package_selection_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';

class NewStudentScreen extends StatefulWidget {
  const NewStudentScreen({super.key});

  @override
  State<NewStudentScreen> createState() => _NewStudentScreenState();
}

class _NewStudentScreenState extends State<NewStudentScreen> {
  String _selectedGender = 'Male';
  String _selectedRelation = 'Mother';
  String _selectedLevel = 'Beginner';
  bool? _isMelodicaStudent = true; // true for 'Yes', false for 'No'

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2004, 2, 8), // Matching screenshot
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // header background color
              onPrimary: AppColors.darkText, // header text color
              onSurface: AppColors.darkText, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Handle the picked date
      print('Selected date: ${picked.toLocal()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.lightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'New Student',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/svg/exit.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              // Handle forward action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/image_upload.png', // Replace with your avatar asset
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // First Name
            const CustomTextField(
              labelText: 'First Name',
              initialValue: 'Jawan',
              suffixIcon: Icon(
                Icons.person_outline,
                color: AppColors.secondaryText,
              ), // User icon
            ),
            const SizedBox(height: 20),

            // Last Name
            const CustomTextField(
              labelText: 'Last Name',
              initialValue: 'Parent',
              suffixIcon: Icon(
                Icons.person_outline,
                color: AppColors.secondaryText,
              ), // User icon
            ),
            const SizedBox(height: 20),

            // Date of Birth & Gender
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'Date of Birth',
                    initialValue: '8 Feb, 2004',
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    suffixIcon: SvgPicture.asset(
                      'assets/svg/schedule.svg',
                      width: 24,
                      height: 24,
                    ), // Calendar icon
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdownField<String>(
                    labelText: 'Gender',
                    value: _selectedGender,
                    items: const ['Male', 'Female', 'Other'],
                    itemToString: (item) => item,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Relation & Level
            Row(
              children: [
                Expanded(
                  child: CustomDropdownField<String>(
                    labelText: 'Relation',
                    value: _selectedRelation,
                    items: const ['Mother', 'Father', 'Guardian'],
                    itemToString: (item) => item,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedRelation = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdownField<String>(
                    labelText: 'Level',
                    value: _selectedLevel,
                    items: const ['Beginner', 'Intermediate', 'Advanced'],
                    itemToString: (item) => item,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLevel = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Radio Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have you been a Melodica student before?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _isMelodicaStudent,
                      onChanged: (value) {
                        setState(() {
                          _isMelodicaStudent = value;
                        });
                      },
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, // Reduce extra padding
                    ),
                    const Text(
                      'Yes i am',
                      style: TextStyle(color: AppColors.darkText),
                    ),
                    const SizedBox(width: 24),
                    Radio<bool>(
                      value: false,
                      groupValue: _isMelodicaStudent,
                      onChanged: (value) {
                        setState(() {
                          _isMelodicaStudent = value;
                        });
                      },
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, // Reduce extra padding
                    ),
                    const Text(
                      'No I am new',
                      style: TextStyle(color: AppColors.darkText),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Next Button
            PrimaryButton(
              text: 'Next',
              onPressed: () {
                print('Next button pressed on New Student screen!');
                // Navigate to PackageSelectionScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PackageSelectionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
