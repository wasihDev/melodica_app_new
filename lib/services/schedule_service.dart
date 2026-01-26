import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/models/schedule_model.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
import 'package:provider/provider.dart';

class ScheduleService {
  static Future<List<ScheduleModel>> getSchedule(BuildContext context) async {
    final ctrl = Provider.of<CustomerController>(context, listen: false);
    final student = ctrl.selectedStudent;
    print('response ${student}');
    final response = await http.get(
      Uri.parse(
        "${ApiConfigService.endpoints.getSchedule}${student!.mbId}",
        // 'https://1ef53198b5bceeb3bf46335729d185.55.environment.api.powerplatform.com/powerautomate/automations/direct/workflows/d871ca1004324568ba2b8084ebca56a4/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=RbWgkV_r76qQTW3YtpikgwV_u3q0jJmSAUKS55dQORk&ClientID=100313948',
      ),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },
    );
    print('response ${response.statusCode}');
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      final List list = decoded['services'] ?? [];

      return list.map((e) => ScheduleModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load schedule');
    }
  }
}
