import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/student_model.dart';
import 'package:melodica_app_new/routes/routes.dart';

class CustomStudentItem extends PopupMenuEntry<String> {
  final Student student;
  final String value;

  const CustomStudentItem({
    super.key,
    required this.student,
    required this.value,
  });

  // Required properties for PopupMenuEntry
  @override
  double get height => 60; // Define the height of the row

  @override
  bool represents(String? value) => this.value == value;

  // Build the custom UI for the student row
  @override
  State<CustomStudentItem> createState() => _CustomStudentItemState();
}

class _CustomStudentItemState extends State<CustomStudentItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Placeholder for the Avatar/Image
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blueAccent[100],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.student.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                widget.student.id,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Custom PopupMenuEntry for "Add New Students" Row ---
class AddStudentItem extends PopupMenuEntry<String> {
  final String value;

  const AddStudentItem({super.key, required this.value});

  @override
  double get height => 60; // Height for this specific row

  @override
  bool represents(String? value) => this.value == value;

  @override
  State<AddStudentItem> createState() => _AddStudentItemState();
}

class _AddStudentItemState extends State<AddStudentItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.newStudent);
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        // This centers the content vertically
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add, color: Colors.black87),
            SizedBox(width: 8),
            Text(
              'Add new students',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
