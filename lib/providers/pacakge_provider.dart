import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/home/faq/help_center.dart';
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

  bool _isLoading = false;
  bool get isloading => _isLoading;
  String? error;

  List<Package> _packages = [];
  List<Package> get packages => _packages;

  DateTime? startDate;
  DateTime? endDate;

  int freezingRemaining = 0;
  ///////////

  Package? selectedPackage;
  String? selectedReason;

  PaymentType? currentPaymentType;

  void setPaymentType(PaymentType type) {
    currentPaymentType = type;
    notifyListeners();
  }

  void setSelectedPackage(Package package) {
    selectedPackage = package;
  }

  void setSelectedReason(String reason) {
    selectedReason = reason;
  }

  ///////////
  void setFreezingRemaining(int value) {
    freezingRemaining = value;
    // print('freezingRemaining $freezingRemaining');
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

  void _showNotEnoughFreezingPopup(
    BuildContext context,
    String danceOrmusic, {
    required VoidCallback ontap,
  }) {
    showDialog(
      context: context,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 18),
                Icon(Icons.warning, color: Colors.orange, size: 40),
                SizedBox(height: 25),

                Text(
                  danceOrmusic == "Dance Classes"
                      ? "You do not have enough remaining freezing allowance.\nAn extension fee is required to proceed"
                      : "You do not have enough remaining freeze allowance.Reschedule to an earlier date or pay an extension fee",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    danceOrmusic == "Dance Classes"
                        ? SizedBox()
                        : Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.dashboard,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              splashColor: AppColors.primary.withOpacity(0.2),
                              highlightColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child: Ink(
                                height: 45.h,
                                width: 110.w,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                // alignment: Alignment.center,
                                child: Center(
                                  child: Text(
                                    'Reschedule',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.fSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    InkWell(
                      onTap: ontap,
                      child: Container(
                        height: 50,
                        width: 110.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/dirham.svg',
                                height: 10.h,
                                width: 10.w,
                              ),
                              Text(
                                " 50",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.fSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "No, thanks",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.fSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  // Future<bool> _isSameClass(String selectedClassId) async {
  //   return freezingRequests.any((r) => r.classId == selectedClassId);
  // }

  // List<FreezingRequest> freezingRequests = [];
  double amountWithVat = 0;
  // double get amountWithVat => _amountWithVat;
  Future<void> submitFreeze(
    BuildContext context,
    String reason,
    Package package,
  ) async {
    selectedPackage = package;
    selectedReason = reason;
    if (startDate == null || endDate == null) return;
    print('package.totalClasses ${package.totalClasses}');
    final bool isFourClassPackage = package.totalClasses == 4;
    // final isSameClass = await _isSameClass(selectedClassId);
    final difference = endDate!.difference(startDate!).inDays;
    if (difference > 28) {
      _showErrorPopup(
        context,
        "The freezing period cannot exceed 4 weeks (28 days).",
      );
      return;
    }
    if (isFourClassPackage) {
      // Show the specific alert: 'You do not have freezing allowance...'
      _showRestrictedFreezingPopup(context);
      return; // Stop the process here
    }
    final isDuplicate = await _isSameClassAndSameDates(
      startDate!,
      endDate!,
      package.danceOrMusic,
    );

    // // 1️⃣ Local validation
    // if (await _isExactMatch(startDate!, endDate!) ) {
    if (isDuplicate) {
      _showErrorPopup(
        context,
        "You have submitted this freezing request before.",
      );
      return;
    }

    // if (await _isOverlapping(startDate!, endDate!)) {
    //   _showErrorPopup(
    //     context,
    //     "You already submitted a freezing request for this class date, adjust your date range if you want to submit another one.",
    //   );
    //   return;
    // }
    if (!hasEnoughFreezing) {
      _showNotEnoughFreezingPopup(
        context,
        selectedPackage!.danceOrMusic,
        // pay here
        ontap: () async {
          servicesProvider.setPaymentType(PaymentType.freezingPoints);

          final vat = extraCharge * 0.05;
          amountWithVat = (extraCharge + vat);

          final success = await servicesProvider.startCheckout(
            context,
            amount: amountWithVat,
          );

          if (success && servicesProvider.paymentUrl != null) {
            final returnVal = await callFreezingApi(
              context,
              reason,
              package,
              ref: servicesProvider.orderReference,
            );
            if (returnVal) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              await launchUrl(
                Uri.parse(servicesProvider.paymentUrl!),
                mode: LaunchMode.externalApplication,
              );
            }
          }
        },
      );
      return;
    }

    // final proceed = await _showConsumePopup(context);
    // if (!proceed) return;

    await callFreezingApi(context, reason, package);
    // 4️⃣ Save request locally after successful submission
  }

  // Save a freezing request locally
  Future<void> _saveFreezingRequest(
    DateTime start,
    DateTime end,
    String className,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('freezingRequests') ?? [];

    final newRequest = jsonEncode({
      "start": start.toIso8601String(),
      "end": end.toIso8601String(),
      "class": className,
    });

    existing.add(newRequest);
    await prefs.setStringList('freezingRequests', existing);
  }

  // Fetch previous freezing requests
  Future<List<Map<String, dynamic>>> _getPreviousRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('freezingRequests') ?? [];
    return existing.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<bool> _isSameClassAndSameDates(
    DateTime start,
    DateTime end,
    String className,
  ) async {
    final previous = await _getPreviousRequests();

    return previous.any(
      (f) =>
          f["start"] == start.toIso8601String() &&
          f["end"] == end.toIso8601String() &&
          f["class"] == className,
    );
  }

  // Check if exact same request exists
  Future<bool> _isExactMatch(DateTime start, DateTime end) async {
    final previous = await _getPreviousRequests();
    return previous.any((f) => f["start"] == start && f["end"] == end);
  }

  // 4 class package popup
  void _showRestrictedFreezingPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 60),
            const SizedBox(height: 16),
            const Text(
              "You do not have freezing allowance, consider rescheduling in advance to avoid session loss.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F), // Melodica Yellow
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<bool> callFreezingApi(
    BuildContext context,
    String reason,
    Package package, {
    String? ref,
  }) async {
    _isLoading = true;
    notifyListeners();
    final bool isMusic = package.danceOrMusic.contains("Music Classes");
    print('isMusic $isMusic');

    // print('package.subject ${package.branch}');
    final affectedClasses = scheduleProvider.getAffectedClasses(
      startDate: startDate!,
      endDate: endDate!,
      subject: package.subject,
    );
    print('affectedClasses $affectedClasses');
    if (affectedClasses.isEmpty) {
      _showErrorPopup(
        context,
        "No classes are affected within the selected date range.Adjust the date range to proceed.",
      );
      _isLoading = false;
      notifyListeners();
      return false;
    }

    print('affectedClasses${affectedClasses}');
    print('reason ${reason}');
    final body = {
      "firstname": "${customerController.customer!.firstName}",
      "lastname": "${customerController.customer!.lastName}",
      "customerid": "${customerController.customer!.mbId.toString()}",
      "relatedcontact":
          "${customerController.students.map((e) => e.mbId).join(",")}",
      "studentfirstname": "${customerController.selectedStudent?.firstName}",
      "studentlastname": "${customerController.selectedStudent?.lastName}",
      "studentid": "${customerController.selectedStudent?.mbId}",
      "subject": "${package.subject}",
      "branch": "${customerController.selectedBranch}",
      "transactionid": "${ref ?? ""}",
      "salesid": "", // i need to pass a transcation id when the payment is done
      "freezingallowance": freezingRemaining,
      "freezingallocation": "Purchased",
      "freezestart": "${startDate!.toUtc().toIso8601String()}",
      "freezeend": "${endDate!.toUtc().toIso8601String()}",
      "affectedclasses": affectedClasses,
      // isMusic ? affectedClasses : [],
      // [
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
      "packageid": "${package.paymentRef}",
      // "checkoutscreen": "",
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfigService.endpoints.freezingRequest),
        headers: {
          "Content-Type": "application/json",
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },
        body: jsonEncode(body),
      );
      print('response ${response.statusCode}');
      print('response freezing api ${response.body}');
      if (response.statusCode == 200) {
        _showSuccessPopup(context);
        await _saveFreezingRequest(startDate!, endDate!, package.danceOrMusic);
        return true;
      } else {
        _showErrorPopup(context, "Something went wrong");
        return false;
      }
    } catch (e) {
      _showErrorPopup(context, e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void showNotCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Welcome to Melodica 🎵",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "It looks like you don’t have an active Melodica account yet.\n\n"
              "This app is currently available for Melodica students only. "
              "If you believe this is a mistake, please contact your branch.",
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpCenter()),
                  );
                  // Navigator.pop(context);
                },
                child: const Text(
                  "Help Center",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (_) => false,
                  );
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
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
    _isLoading = true;
    error = null;
    notifyListeners();
    final ctrl = Provider.of<CustomerController>(context, listen: false);
    final student = ctrl.selectedStudent;
    try {
      final response = await http.get(
        Uri.parse("${ApiConfigService.endpoints.getPackages}${student?.mbId}"),
        headers: {
          'Content-Type': 'application/json',
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },
      );
      print('fetchPackages.statusCode ${response.statusCode}');
      // print('fetchPackages.body ${response.body}');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _packages = data.map((e) => Package.fromJson(e)).toList();
        // print('_packages =====>>m $_packages');
        if (_packages.length == 0) {
          _isLoading = false;
          notifyListeners();
        }

        /// 🔑 Extract unique branches
        final branches = _packages.map((e) => e.branch).toSet().toList();
        print('branch ===>> $branches');
        if (branches.length == 1) {
          /// ✅ Single branch → auto select
          ctrl.setSelectedBranch(branches.first);
        } else if (branches.length == 0 && branches.isEmpty) {
          if (!customerController.isCustomerRegistered) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showNotCustomerDialog(navigatorKey.currentContext!);
            });
          }
          print('branches.length == 0 && branches.isEmpty');
          return;
        } else {
          /// ❌ Multiple branches → ask user
          await _showBranchSelectionDialog(context, branches);
        }
      } else {
        error = 'Failed to load packages';
      }
    } catch (e) {
      _isLoading = false;
      print('error fetchPackages $e');
      error = e.toString();
    }

    _isLoading = false;
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

  Future<void> _showBranchSelectionDialog(
    BuildContext context,
    List<String> branches,
  ) async {
    final customerCtrl = Provider.of<CustomerController>(
      context,
      listen: false,
    );

    String? selectedBranch;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Branch'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: branches.map((branch) {
                  return RadioListTile<String>(
                    title: Text(branch),
                    value: branch,
                    groupValue: selectedBranch,
                    onChanged: (value) {
                      setState(() {
                        selectedBranch = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                ElevatedButton(
                  onPressed: selectedBranch == null
                      ? null
                      : () async {
                          customerCtrl.setSelectedBranch(selectedBranch!);

                          final cusprovider = Provider.of<CustomerController>(
                            context,
                            listen: false,
                          );
                          print('selectedBranch ${selectedBranch}');
                          await cusprovider.getDisplayDance(selectedBranch!);
                          Navigator.pop(context);
                        },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
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
