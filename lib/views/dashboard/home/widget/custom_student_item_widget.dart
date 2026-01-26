import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/student_models.dart';

class CustomStudentItem extends PopupMenuItem<String> {
  CustomStudentItem({
    super.key,
    required Student student,
    required String value,
  }) : super(
         value: value, // 🔥 REQUIRED
         height: 56,
         child: Row(
           children: [
             CircleAvatar(
               radius: 16,
               child: Text(
                 '${student.firstName.toUpperCase().substring(0, 1)}',
               ),
             ),
             const SizedBox(width: 10),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(
                   student.fullName,
                   style: const TextStyle(fontWeight: FontWeight.w600),
                 ),
                 Text(
                   "${student.mbId}",
                   style: const TextStyle(fontSize: 12, color: Colors.grey),
                 ),
               ],
             ),
           ],
         ),
       );
}
