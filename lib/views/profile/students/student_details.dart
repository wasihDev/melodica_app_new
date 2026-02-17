import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/student_models.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
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
      DateTime parsedDate = DateFormat("yyyy-M-d").parse(rawDate);
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

  // static Widget _readOnlyBox(String value) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey.shade300),
  //     ),
  //     child: Text(value, style: TextStyle(fontSize: 12.fSize)),
  //   );
  // }
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
