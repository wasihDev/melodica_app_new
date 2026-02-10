import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/models/teacher_slots_models.dart';
import 'package:melodica_app_new/services/api_config_service.dart';

class RescheduleService {
  Future<List<TeacherSlot>> getAvailability(
    String date,
    String resourceId,
    int duration,
    String Subject,
    String Branch,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConfigService.endpoints.getAvailability),
      headers: {
        "Content-Type": "application/json",
        'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
      },
      body: jsonEncode({
        "Date": date.toString().split(' ').first, // YYYY-MM-DD
        "Resource": resourceId,
        "Duration": duration,
        "Subject": Subject,
        "Branch": Branch,
      }),
    );
    print('getAvailability.statusCode ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print('data ${data}');
      // List services = data['services'] ?? [];
      // print('services ${services}');
      final List<dynamic> rows = data['rows'] ?? [];

      // Convert each row to TeacherSlot
      return rows.map((s) => TeacherSlot.fromJson(s)).toList();
    } else {
      throw Exception("Failed to load availability");
    }
  }
}

// class AvailabilitySlot {
//   final String slotsRange;

//   AvailabilitySlot({required this.slotsRange});

//   factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
//     return AvailabilitySlot(slotsRange: json['slot']);
//   }
// }

class AvailabilitySlot {
  String slotsRange; // <-- the string from API like "15:00 - 15:45"
  late DateTime startTime;
  late DateTime endTime;
  bool isOngoing = false;

  AvailabilitySlot({required this.slotsRange});

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(slotsRange: json['slot'] as String);
  }
}
