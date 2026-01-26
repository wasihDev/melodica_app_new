import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PackageProvider extends ChangeNotifier {
  CustomerController customerController;
  ServicesProvider servicesProvider;
  ScheduleProvider scheduleProvider;

  PackageProvider({
    required this.customerController,
    required this.servicesProvider,
    required this.scheduleProvider,
  });

  bool isLoading = false;
  String? error;

  List<Package> _packages = [];
  List<Package> get packages => _packages;

  DateTime? startDate;
  DateTime? endDate;

  int freezingRemaining = 0;

  void setFreezingRemaining(int value) {
    freezingRemaining = value;
    print('freezingRemaining $freezingRemaining');
    notifyListeners();
  }

  int get freezeDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  int get freezeWeeks => (freezeDays / 7).ceil();

  bool get hasEnoughFreezing => freezeWeeks <= freezingRemaining;

  /// EXTRA WEEKS USER IS REQUESTING

  /// FINAL AMOUNT USER NEEDS TO PAY
  int get extraWeeks {
    final extra = freezeWeeks - freezingRemaining;
    return extra > 0 ? extra : 0;
  }

  int get extraCharge {
    if (extraWeeks <= 0) return 0;
    return extraWeeks * 50;
  }

  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    endDate = date;
    notifyListeners();
  }

  void _showNotEnoughFreezingPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsPadding: EdgeInsets.only(bottom: 20, right: 10),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Colors.white,
        title: Icon(Icons.warning, color: Colors.orange, size: 40),
        content: Text(
          "You do not have enough remaining freezing.\nConsider purchasing extensions",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "No, thanks",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              servicesProvider.setPaymentType(PaymentType.freezingPoints);
              final vat = extraCharge * 0.05;
              final amountWithVat = (extraCharge + vat).toInt();

              final success = await servicesProvider.startCheckout(
                context,
                amount: amountWithVat,
                redirectUrl: "https://melodica-mobile.web.app",
              );

              if (success && servicesProvider.paymentUrl != null) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                await launchUrl(
                  Uri.parse(servicesProvider.paymentUrl!),
                  mode: LaunchMode.externalApplication,
                );
              }
              // servicesProvider.startCheckout(amount:extraCharge, redirectUrl: '' )
            },
            child: Container(
              height: 50,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "AED ${extraCharge * 1.05}",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            },
            child: Text(
              'Reschedule',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConsumePopup(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: Icon(Icons.warning, color: Colors.orange, size: 40),
            content: Text(
              "You're about to consume your Freezing.\nWould like to proceed?",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("No"),
              ),
              InkWell(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Icon(Icons.check_circle, color: Colors.green, size: 40),
        content: Text(
          "Your request has been submitted.\nOur team will get back to you.",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitFreeze(
    BuildContext context,
    String reason,
    Package package,
  ) async {
    if (startDate == null || endDate == null) return;

    // // 1️⃣ Local validation
    if (await _isExactMatch(startDate!, endDate!)) {
      _showErrorPopup(
        context,
        "You have submitted this freezing request before.",
      );
      return;
    }

    if (await _isOverlapping(startDate!, endDate!)) {
      _showErrorPopup(
        context,
        "You have overlapping freezing dates with a previous submission.",
      );
      return;
    }
    if (!hasEnoughFreezing) {
      _showNotEnoughFreezingPopup(context);
      return;
    }

    final proceed = await _showConsumePopup(context);
    if (!proceed) return;

    await _callFreezingApi(context, reason, package);
    // 4️⃣ Save request locally after successful submission
    await _saveFreezingRequest(startDate!, endDate!);
  }

  // Save a freezing request locally
  Future<void> _saveFreezingRequest(DateTime start, DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('freezingRequests') ?? [];

    final newRequest = jsonEncode({
      "start": start.toIso8601String(),
      "end": end.toIso8601String(),
    });

    existing.add(newRequest);
    await prefs.setStringList('freezingRequests', existing);
  }

  // Fetch previous freezing requests
  Future<List<Map<String, DateTime>>> _getPreviousRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('freezingRequests') ?? [];

    return existing.map((e) {
      final data = jsonDecode(e);
      return {
        "start": DateTime.parse(data["start"]),
        "end": DateTime.parse(data["end"]),
      };
    }).toList();
  }

  // Check if exact same request exists
  Future<bool> _isExactMatch(DateTime start, DateTime end) async {
    final previous = await _getPreviousRequests();
    return previous.any((f) => f["start"] == start && f["end"] == end);
  }

  // Check if dates overlap
  Future<bool> _isOverlapping(DateTime start, DateTime end) async {
    final previous = await _getPreviousRequests();
    for (var f in previous) {
      final s = f["start"]!;
      final e = f["end"]!;
      if (start.isBefore(e.add(const Duration(days: 1))) &&
          end.isAfter(s.subtract(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }

  Future<void> _callFreezingApi(
    BuildContext context,
    String reason,
    Package package,
  ) async {
    isLoading = true;
    notifyListeners();
    print(
      'startDate!.toUtc().toIso8601String() ${startDate!.toUtc().toIso8601String()}',
    );
    final affectedClasses = scheduleProvider.getAffectedClasses(
      startDate: startDate!,
      endDate: endDate!,
    );
    if (affectedClasses.isEmpty) {
      _showErrorPopup(context, "No classes found in selected date range");
      isLoading = false;
      notifyListeners();
      return;
    }

    print('affectedClasses ${affectedClasses}');
    print('reason ${reason}');
    final body = {
      "firstname": customerController.customer!.firstName,
      "lastname": customerController.customer!.lastName,
      "customerid": customerController.customer!.mbId.toString(),
      "relatedcontact":
          "${customerController.students.map((e) => e.mbId).join(",")}",
      "studentfirstname": "${customerController.selectedStudent?.firstName}",
      "studentlastname": "${customerController.selectedStudent?.lastName}",
      "studentid": "${customerController.selectedStudent?.mbId}",
      "subject": "${package.subject}",
      "branch": "${customerController.customer?.territoryid}",
      "transactionid": "16866b7e-d056-4b08-9e6e-a3797a63bae7",
      "salesid": "APP-208637",
      "freezingallowance": freezingRemaining,
      "freezingallocation": "Purchased",
      "freezestart": startDate!.toUtc().toIso8601String(),
      "freezeend": endDate!.toUtc().toIso8601String(),
      "affectedclasses": affectedClasses,
      //  [
      //   {
      //     "bookingid": "10010340088375110",
      //     "bookingstart": startDate!.toUtc().toIso8601String(),
      //   },
      //   // {
      //   //   "bookingid": "10010340088375110",
      //   //   "bookingstart": "2026-03-01T15:00:00Z",
      //   // },
      // ],
      "reason": "${reason}",
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfigService.endpoints.freezingRequest),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      print('response.statusCode ${response.statusCode}');
      if (response.statusCode == 200) {
        _showSuccessPopup(context);
      } else {
        _showErrorPopup(context, "Something went wrong");
      }
    } catch (e) {
      _showErrorPopup(context, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _showErrorPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Icon(Icons.error_outline, color: Colors.red, size: 44),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchPackages(BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();
    final ctrl = Provider.of<CustomerController>(context, listen: false);
    final student = ctrl.selectedStudent;
    try {
      print('student!.mbId ${student!.mbId}');
      final response = await http.get(
        Uri.parse("${ApiConfigService.endpoints.getPackages}${student.mbId}"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _packages = data.map((e) => Package.fromJson(e)).toList();
      } else {
        error = 'Failed to load packages';
      }
    } catch (e) {
      print('error $e');
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // shared prefrences

  Future<void> saveFreezingRequest(DateTime start, DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('freezingRequests') ?? [];

    final newRequest = jsonEncode({
      "start": start.toIso8601String(),
      "end": end.toIso8601String(),
    });

    existing.add(newRequest);
    await prefs.setStringList('freezingRequests', existing);
  }

  Future<List<Map<String, DateTime>>> getPreviousRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('freezingRequests') ?? [];

    return existing.map((e) {
      final data = jsonDecode(e);
      return {
        "start": DateTime.parse(data["start"]),
        "end": DateTime.parse(data["end"]),
      };
    }).toList();
  }

  Future<bool> isExactMatch(DateTime start, DateTime end) async {
    final previous = await getPreviousRequests();
    return previous.any((f) => f["start"] == start && f["end"] == end);
  }

  Future<bool> isOverlapping(DateTime start, DateTime end) async {
    final previous = await getPreviousRequests();
    for (var f in previous) {
      final s = f["start"]!;
      final e = f["end"]!;
      if (start.isBefore(e.add(const Duration(days: 1))) &&
          end.isAfter(s.subtract(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }
}
