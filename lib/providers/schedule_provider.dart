import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/schedule_model.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
import 'package:melodica_app_new/services/schedule_service.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/utils/responsive_sizer.dart';

class ScheduleProvider extends ChangeNotifier {
  CustomerController customerController;
  ServicesProvider servicesProvider;

  ScheduleProvider({
    required this.customerController,
    required this.servicesProvider,
  });

  List<ScheduleModel> schedules = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _paymentUrl;
  String? get paymentUrl => _paymentUrl;
  String? _orderReference;
  String? get orderReference => _orderReference;

  DateTime? selectedDate;

  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 24,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 20),
            Text(
              'Please wait a moment..',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> fetchSchedule(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      schedules = await ScheduleService.getSchedule(context);
    } catch (e) {
      debugPrint('Schedule error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void showPaymentSuccessDialog(
    BuildContext context, {
    String title = "Payment Successful",
    String message = "Your payment has been completed successfully.",
    VoidCallback? onDone,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 45.h,
              width: 45.w,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF47C97E), width: 4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  size: 30.adaptSize,
                  color: Color(0xFF47C97E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDone?.call();
                },
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getAffectedClasses({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return schedules
        .where((s) {
          final dt = s.bookingDateTime;
          if (dt == null) return false;

          // Normalize to UTC for comparison
          final utc = dt.toUtc();

          return (utc.isAfter(startDate.toUtc()) ||
                  utc.isAtSameMomentAs(startDate.toUtc())) &&
              (utc.isBefore(endDate.toUtc()) ||
                  utc.isAtSameMomentAs(endDate.toUtc()));
        })
        .map(
          (s) => {
            "bookingid": s.bookingId,
            "bookingstart": s.bookingDateTime!.toUtc().toIso8601String(),
          },
        )
        .toList();
  }

  Future<bool> submitScheduleRequest({
    required String subject,
    required String classDateTime,
    required String action,
    required String packageid,
    required String preferredSlot,
    required String branch,
    required String reason,
    String transactionId = "",
  }) async {
    _isLoading = true;
    notifyListeners();
    // print(
    //   'customerController.customer!.firstName ${customerController.customer!.firstName}',
    // );
    // print('customerController2 ${customerController.customer!.firstName}');
    // print('customerController4 ${customerController.customer!.lastName}');
    // print(
    //   'customerController3 ${customerController.students.map((e) => e.mbId).join(",")}',
    // );
    // print('customerController5 ${customerController.selectedStudent!.mbId}');
    // print('customerController6 ${subject}');

    // print('customerController7 ${classDateTime}');
    // print('customerController8 ${preferredSlot}');
    // print('bracj ${customerController.customer!.territoryid}');
    // print(
    //   'customerController ${customerController.selectedStudent!.firstName}',
    // );
    try {
      final response = await http.post(
        Uri.parse(ApiConfigService.endpoints.postCancellation),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstname": "${customerController.customer!.firstName}",
          "lastname": "${customerController.customer?.lastName ?? ""}",
          "customerid":
              "${customerController.students.map((e) => e.mbId).join(",")}",
          "studentfirstname":
              "${customerController.selectedStudent!.firstName}",
          "studentlastname": "${customerController.selectedStudent!.lastName}",
          "studentid": "${customerController.selectedStudent!.mbId}",
          "branch": branch,
          "subject": "${subject}",
          "classdatetime": "${classDateTime}",
          "action": action,
          "packageid": "${packageid}",
          "preferredslot": "${preferredSlot}",
          "reason": reason,
          "transactionid": "${transactionId}",
        }),
      );
      print('response.statusCode ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // error = response.body;
        return false;
      }
    } catch (e) {
      print('error submist reqeust $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0); // 12:00 AM
  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59); // 11:59 PM

  /// 🔹 Convert TimeOfDay → minutes
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  List<ScheduleModel> get upcomingSchedules {
    final now = DateTime.now();
    return schedules.where((s) {
        // ❌ REMOVE empty / dummy schedules
        if (s.bookingDateTime == null) return false;
        if (s.bookingRoom == '') return false;
        if (s.bookingDay == null || s.bookingDay!.isEmpty) return false;
        if (s.day == null || s.day == 0) return false;
        if (s.monthShort == null || s.monthShort!.isEmpty) return false;
        final bookingDate = s.bookingDateTime!;
        // ✅ upcoming date only
        if (!bookingDate.isAfter(now)) return false;
        // ✅ time filter
        final bookingMinutes = bookingDate.hour * 60 + bookingDate.minute;
        return bookingMinutes >= _toMinutes(startTime) &&
            bookingMinutes <= _toMinutes(endTime);
      }).toList()
      ..sort((a, b) => a.bookingDateTime!.compareTo(b.bookingDateTime!));
  }
  // List<ScheduleModel> get upcomingSchedules {
  //   final now = DateTime.now();

  //   return schedules.where((s) {
  //       if (s.bookingDateTime == null) return false;
  //       if (s.bookingRoom == '') return false;
  //       if (s.bookingDay == null || s.bookingDay!.isEmpty) return false;
  //       if (s.day == null || s.day == 0) return false;
  //       if (s.monthShort == null || s.monthShort!.isEmpty) return false;

  //       final start = s.bookingDateTime!;
  //       final end = s.endDateTime;

  //       // Keep the class if:
  //       // 1️⃣ It's upcoming OR 2️⃣ It's ongoing
  //       return end.isAfter(now);
  //     }).toList()
  //     ..sort((a, b) => a.bookingDateTime!.compareTo(b.bookingDateTime!));
  // }

  Set<DateTime> get availableDates {
    // Extract all booking dates, normalize to midnight (Year, Month, Day only)
    return schedules
        .map((s) => s.bookingDateTime)
        .whereType<DateTime>() // Filter out any nulls
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  void clearFilter() {
    startTime = TimeOfDay(hour: 0, minute: 0); // 12:00 AM;
    endTime = TimeOfDay(hour: 23, minute: 59);

    notifyListeners();
  }

  /// 🔹 Update time range
  void updateTimeRange(TimeOfDay start, TimeOfDay end) {
    startTime = start;
    endTime = end;
    notifyListeners();
  }
}
