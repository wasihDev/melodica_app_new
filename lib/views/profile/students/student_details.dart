import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/student_models.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class StudentDetails extends StatelessWidget {
  Student student;
  bool isShowNextbtn;
  StudentDetails({
    super.key,
    required this.student,
    required this.isShowNextbtn,
  });

  String formatMyDate(String rawDate) {
    try {
      // 1. Logic for cleaning/fixing invalid data if necessary
      // If the API literally sends '32', we should cap it at the last day of the month
      // For now, let's assume it's a valid string like '1992-01-31'

      // 2. Parse the input (yyyy-M-d handles single digits like '1' automatically)
      DateTime parsedDate = DateFormat("yyyy-M-d").parse(rawDate);

      // 3. Format to the desired output: 31-Jan-1992
      return DateFormat("d MMM yyyy").format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Student Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Consumer<CustomerController>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  // const SizedBox(height: 8),

                  /// Avatar
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        // backgroundColor: Colors.grey.shade300,
                        backgroundImage: const AssetImage(
                          'assets/images/image_upload.png', // replace with network if needed
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _label('First Name'),
                  _readOnlyField(student.firstName, Icons.person),
                  SizedBox(height: 10.h),
                  _label('Last Name'),
                  _readOnlyField(student.lastName, Icons.person_outline),
                  SizedBox(height: 10.h),
                  _label('Email'),
                  _readOnlyField(
                    student.email,
                    Icons.email_outlined,
                    filled: true,
                  ),

                  // SizedBox(height: 10.h),
                  // _label('Phone Number'),
                  // Row(
                  //   children: [
                  //     Expanded(child: _readOnlyBox('ARE-971')),
                  //     const SizedBox(width: 8),
                  //     Expanded(child: _readOnlyBox('54 ▼')),
                  //     const SizedBox(width: 8),
                  //     Expanded(flex: 2, child: _readOnlyBox('')),
                  //   ],
                  // ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Date of Birth'),
                            _readOnlyField(
                              formatMyDate(student.dateOfBirth),
                              Icons.calendar_today,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Gender'),
                            _readOnlyDropdown(student.gender),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 0),

                  // Row(
                  //   children: [
                  //     // Expanded(
                  //     //   child: Column(
                  //     //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     //     children: [
                  //     //       _label('Relation'),
                  //     //       // _readOnlyDropdown(student.),
                  //     //     ],
                  //     //   ),
                  //     // ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           _label('Level'),
                  //           _readOnlyDropdown('Beginner'),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 20),

                  _label('Have you been a Melodica student before?'),
                  Row(
                    children: const [
                      _DisabledRadio(label: 'Yes i am', selected: false),
                      SizedBox(width: 24),
                      _DisabledRadio(label: 'No i am new', selected: true),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// Next Button
                  isShowNextbtn
                      ? SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF7CD3C),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              );
            },
          ),
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.only(bottom: 20.0.h, left: 20.w, right: 20.w),
      //   child: _buildAddStudentSection(context),
      // ),
    );
  }

  Widget _buildAddStudentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: CustomButton(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.newStudent);
        },
        widget: Text(
          'Update Student',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  /// Helpers
  static Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ),
    );
  }

  static Widget _readOnlyField(
    String value,
    IconData icon, {
    bool filled = false,
  }) {
    return TextField(
      readOnly: true,
      enabled: false,
      decoration: InputDecoration(
        hintText: value,
        hintStyle: TextStyle(fontSize: 14.fSize),
        suffixIcon: Icon(icon),
        filled: filled,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  static Widget _readOnlyDropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: TextStyle(color: Colors.grey[500])),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  static Widget _readOnlyBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(value, style: TextStyle(fontSize: 12.fSize)),
    );
  }
}

/// Disabled Radio Widget
class _DisabledRadio extends StatelessWidget {
  final String label;
  final bool selected;

  const _DisabledRadio({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

// class StudentDetails extends StatefulWidget {
//   const StudentDetails({super.key});

//   @override
//   State<StudentDetails> createState() => _NewStudentScreenState();
// }

// class _NewStudentScreenState extends State<StudentDetails> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightGrey,
//       appBar: AppBar(
//         backgroundColor: AppColors.lightGrey,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'New Student',
//           style: TextStyle(
//             color: AppColors.darkText,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//       ),

//       // final ctrl = Provider.of<CustomerController>(context, listen: false);
      // body: Consumer<CustomerController>(
      //   builder: (context, provider, child) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Avatar
//                 Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: AppColors.primary, width: 3),
//                   ),
//                   child: ClipOval(
//                     child: Image.asset(
//                       'assets/images/image_upload.png', // Replace with your avatar asset
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => const Icon(
//                         Icons.person,
//                         size: 60,
//                         color: AppColors.secondaryText,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // First Name
//                 const CustomTextField(
//                   labelText: 'First Name',
//                   initialValue: 'first name',
//                   suffixIcon: Icon(
//                     Icons.person_outline,
//                     color: AppColors.secondaryText,
//                   ), // User icon
//                 ),
//                 const SizedBox(height: 20),

//                 // Last Name
//                 const CustomTextField(
//                   labelText: 'Last Name',
//                   initialValue: 'last name',
//                   suffixIcon: Icon(
//                     Icons.person_outline,
//                     color: AppColors.secondaryText,
//                   ), // User icon
//                 ),
//                 const SizedBox(height: 20),

//                 // Date of Birth & Gender
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomTextField(
//                         labelText: 'Date of Birth',
//                         initialValue: '8 Feb, 2004',
//                         readOnly: true,
//                         // onTap: () => _selectDate(context),
//                         suffixIcon: SvgPicture.asset(
//                           'assets/svg/schedule.svg',
//                           width: 24,
//                           height: 24,
//                         ), // Calendar icon
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: CustomDropdownField<String>(
//                         labelText: 'Gender',
//                         value: provider.customer!.gender,
//                         items: const ['', 'Male', 'Female', 'Other'],
//                         itemToString: (item) => item,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // Relation & Level
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomDropdownField<String>(
//                         labelText: 'Relation',
//                         value: _selectedRelation,
//                         items: const ['', 'Mother', 'Father', 'Guardian'],
//                         itemToString: (item) => item,
//                         onChanged: (newValue) {
//                           if (newValue != null) {
//                             setState(() {
//                               _selectedRelation = newValue;
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: CustomDropdownField<String>(
//                         labelText: 'Level',
//                         value: _selectedLevel,
//                         items: const [
//                           '',
//                           'Beginner',
//                           'Intermediate',
//                           'Advanced',
//                         ],
//                         itemToString: (item) => item,
//                         onChanged: (newValue) {
//                           if (newValue != null) {
//                             setState(() {
//                               _selectedLevel = newValue;
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // Radio Buttons
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Have you been a Melodica student before?',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: AppColors.secondaryText,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Radio<bool>(
//                           value: true,
//                           groupValue: _isMelodicaStudent,
//                           onChanged: (value) {
//                             setState(() {
//                               _isMelodicaStudent = value;
//                             });
//                           },
//                           activeColor: AppColors.primary,
//                           materialTapTargetSize: MaterialTapTargetSize
//                               .shrinkWrap, // Reduce extra padding
//                         ),
//                         const Text(
//                           'Yes i am',
//                           style: TextStyle(color: AppColors.darkText),
//                         ),
//                         const SizedBox(width: 24),
//                         Radio<bool>(
//                           value: false,
//                           groupValue: _isMelodicaStudent,
//                           onChanged: (value) {
//                             setState(() {
//                               _isMelodicaStudent = value;
//                             });
//                           },
//                           activeColor: AppColors.primary,
//                           materialTapTargetSize: MaterialTapTargetSize
//                               .shrinkWrap, // Reduce extra padding
//                         ),
//                         const Text(
//                           'No I am new',
//                           style: TextStyle(color: AppColors.darkText),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40),

//                 // Next Button
//                 PrimaryButton(
//                   text: 'Next',
//                   onPressed: () {
//                     print('Next button pressed on New Student screen!');
//                     // Navigate to PackageSelectionScreen
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             PackageSelectionScreen(isShowdanceTab: true),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
