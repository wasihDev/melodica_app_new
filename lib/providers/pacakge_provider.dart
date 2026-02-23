import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/freezing_period_model.dart';
import 'package:melodica_app_new/models/get_cancellation_model.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
import 'package:melodica_app_new/views/profile/packages/widget/affected_classes_screen.dart';
import 'package:melodica_app_new/views/profile/packages/widget/packages_dialog_service.dart';
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
  String? error;
  DateTime? startDate;
  DateTime? endDate;
  int freezingRemaining = 0;
  Package? selectedPackage;
  String? selectedReason;
  List<GetCancellationModel> _requests = [];
  PaymentType? currentPaymentType;
  List<Package> _packages = [];
  List<FreezingSeason> seasons = [];
  bool _isLoadingforSeason = false;

  bool get isLoadingforSeason => _isLoadingforSeason;
  List<Package> get packages => _packages;
  bool get isloading => _isLoading;
  List<GetCancellationModel> get requests => _requests;

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

  void resetEndDate() {
    endDate = null;
    startDate = null;
  }

  void setFreezingRemaining(int value) {
    freezingRemaining = value;
    // print('freezingRemaining $freezingRemaining');
    notifyListeners();
  }

  int get freezeDays {
    if (startDate == null || endDate == null) return 0;

    int totalDays = endDate!.difference(startDate!).inDays + 1;

    final season = currentSeason;
    if (season == null) return totalDays; // no season → full charge

    final sStart = DateTime(
      season.startDate.year,
      season.startDate.month,
      season.startDate.day,
    );

    final sEnd = DateTime(
      season.endDate.year,
      season.endDate.month,
      season.endDate.day,
    );

    final uStart = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final uEnd = DateTime(endDate!.year, endDate!.month, endDate!.day);

    final overlapStart = uStart.isAfter(sStart) ? uStart : sStart;
    final overlapEnd = uEnd.isBefore(sEnd) ? uEnd : sEnd;

    int seasonDays = 0;

    if (!overlapEnd.isBefore(overlapStart)) {
      seasonDays = overlapEnd.difference(overlapStart).inDays + 1;
    }

    // Only days OUTSIDE season will be charged
    return totalDays - seasonDays;
  }

  int get freezeWeeks {
    final days = freezeDays;
    if (days <= 0) return 0;
    return (days / 7).ceil();
  }

  bool get hasEnoughFreezing {
    return extraFreezeWeeks == 0;
  }

  int get extraFreezeWeeks {
    final extra = freezeWeeks - freezingRemaining;
    return extra > 0 ? extra : 0;
  }

  bool get isFullyInsideSeason => freezeDays == 0;

  double get totalWithVat {
    if (extraCharge == 0) return 0;

    final vat = extraCharge * 0.05;
    return extraCharge + vat;
  }

  int get extraWeeks {
    if (isFullyInsideSeason) return 0;

    final extra = freezeWeeks - freezingRemaining;
    return extra > 0 ? extra : 0;
  }

  int get extraCharge {
    if (freezeWeeks == 0) return 0;
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

  Future<void> fetchRescheduleRequests({
    required String packageId,
    required String clientId,
  }) async {
    _isLoading = true;
    notifyListeners();
    final String url = ApiConfigService.endpoints.getCancellation;
    print('url $url');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },
        body: jsonEncode({"packageid": packageId, "clientid": clientId}),
      );
      print('response.statusCode ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _requests = data
            .map((json) => GetCancellationModel.fromJson(json))
            .toList();
        print('_requests ${_requests}');
      }
    } catch (e) {
      print('error $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  FreezingSeason? getActiveSeasonForDates(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (seasons.isEmpty) return null;

    for (final season in seasons) {
      if (season.status.toLowerCase() != 'active') continue;

      final sStart = DateTime(
        season.startDate.year,
        season.startDate.month,
        season.startDate.day,
      );

      final sEnd = DateTime(
        season.endDate.year,
        season.endDate.month,
        season.endDate.day,
      );

      final uStart = DateTime(startDate.year, startDate.month, startDate.day);
      final uEnd = DateTime(endDate.year, endDate.month, endDate.day);

      final isOverlap =
          uStart.isBefore(sEnd.add(const Duration(days: 1))) &&
          uEnd.isAfter(sStart.subtract(const Duration(days: 1)));

      if (isOverlap) return season;
    }

    return null;
  }

  bool get isSeasonApplied => currentSeason != null;

  bool? _validateSeasonDuration(
    BuildContext context,
    DateTime startDate,
    DateTime endDate,
  ) {
    final season = getActiveSeasonForDates(startDate, endDate);
    print('season ${season}');

    // No active season → use normal validation later
    if (season == null) return null;
    print('season.max ${season.max}');
    var max = season.max;
    //"2";

    // Max is blank → no validation
    if (max == "") return true;
    final freezeWeeks = this.freezeWeeks;
    // final freezeWeeks = (freezeDays / 7).ceil();
    print('====>> $freezeWeeks ${max}');
    if (freezeWeeks > num.parse(max)) {
      PopupService.showErrorPopup(
        context,
        "During ${season.name}, freezing cannot exceed ${max} week(s).",
      );
      return false;
    }

    return true;
  }

  // bool get isSeasonApplied => _validateSeasonDuration != null;
  FreezingSeason? get currentSeason {
    if (startDate == null || endDate == null) return null;
    return getActiveSeasonForDates(startDate!, endDate!);
  }

  double amountWithVat = 0;
  Future<void> submitFreeze(
    BuildContext context,
    String reason,
    Package package,
  ) async {
    selectedPackage = package;
    selectedReason = reason;
    print('season $seasons');
    if (startDate == null || endDate == null) return;
    print('startDate ${startDate}');
    // SEASON CHECK FIRST
    // ///  Fully inside season → FREE
    if (isFullyInsideSeason) {
      print('Fully inside season → free');
      await callFreezingApi(context, reason, package);
      return;
    }

    /// 2️⃣ Validate season max (if season exists)
    final seasonValidation = _validateSeasonDuration(
      context,
      startDate!,
      endDate!,
    );

    if (seasonValidation == false) {
      // exceeded season max
      print('=========>>>> VALIDATE FOR MAX <<<<==========');
      return;
    }
    // ==================== Normal validations (outside season)  ====================
    // Yes means block i cannot freeze ( "4 Classes": "Yes" )
    final bool isFourClassPackage = package.totalClasses == 4;
    if (freezeWeeks > 4) {
      PopupService.showErrorPopup(
        context,
        "The freezing period cannot exceed 4 weeks (28 days).",
      );
      return;
    }

    if (isFourClassPackage) {
      PopupService.showRestrictedFreezingPopup(context);
      return;
    }
    final isDuplicate = await _isSameClassAndSameDates(
      startDate!,
      endDate!,
      package.danceOrMusic,
    );

    if (isDuplicate) {
      PopupService.showErrorPopup(
        context,
        "You have submitted this freezing request before.",
      );
      return;
    }
    if (!hasEnoughFreezing) {
      PopupService.showNotEnoughFreezingPopup(
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
        price: '$extraCharge',
        // ontapReschedule: () {
        //   final provider = Provider.of<PackageProvider>(context, listen: false);
        //   final affected = provider.scheduleProvider.getAffectedClasses(
        //     startDate: provider.startDate!,
        //     endDate: provider.endDate!,
        //     subject: package.subject,
        //   );
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => AffectedClassesScreen(
        //         affectedClasses: affected,
        //         subject: package.subject,
        //       ),
        //     ),
        //   );
        // },
      );
      return;
    }

    // ================= EXPIRY VALIDATION =================
    final expiryDate = DateTime.parse(package.packageExpiry);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);

    if (start.isAfter(exp)) {
      PopupService.showErrorPopup(
        context,
        "Freezing cannot start after the package expiry date.",
      );
      return;
    }
    // final proceed = await _showConsumePopup(context);
    // if (!proceed) return;
    print('====>>> calling');
    await callFreezingApi(context, reason, package);
    // 4️⃣ Save request locally after successful submission
  }

  Future<bool> callFreezingApi(
    BuildContext context,
    String reason,
    Package package, {
    String? ref,
  }) async {
    _isLoading = true;
    notifyListeners();
    if (ref == null || ref.isEmpty) {
      servicesProvider.clearPaymentData();
    }
    final affectedClasses = scheduleProvider.getAffectedClasses(
      startDate: startDate!,
      endDate: endDate!,
      subject: package.subject,
    );
    final nextClassDate = scheduleProvider.getNextClassAfterEndDate(
      endDate: endDate!,
      subject: package.subject,
    );
    // last affacteed and
    print("======================================");
    print("Next class date: $nextClassDate");
    print("======================================");

    if (affectedClasses.isEmpty) {
      PopupService.showErrorPopup(
        context,
        "No classes are affected within the selected date range.Adjust the date range to proceed.",
      );
      _isLoading = false;
      notifyListeners();
      return false;
    }

    print('freezingRemaining  ===>> ${freezingRemaining}');
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
      "freezingallowance": freezingRemaining,
      "freezingallocation": "", // Purchased
      "freezestart": "${startDate!.toIso8601String()}",
      "freezeend": "${endDate!.toIso8601String()}",
      "affectedclasses": affectedClasses,
      "reason": "${reason}",
      "packageid": "${package.paymentRef}",
      "expiry": package.packageExpiry,
      // "checkoutscreen": "",
    };

    if (servicesProvider.orderId != null &&
        servicesProvider.orderReference != null) {
      body['transactionid'] = servicesProvider.orderId!;
      body['salesid'] = servicesProvider.orderReference!;
    }
    if (nextClassDate?.toIso8601String() != null) {
      body['nextdate'] = "${nextClassDate?.toIso8601String()}";
    }
    print("Body===>>  ${body}");
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
        if (nextClassDate == null) {
          PopupService.showNoUpcomingClassesPopup(context, endDate, startDate);
        } else {
          PopupService.showSuccessPopup(context, endDate, startDate);
        }
        await _saveFreezingRequest(startDate!, endDate!, package.danceOrMusic);
        return true;
      } else {
        PopupService.showErrorPopup(context, "Something went wrong");
        return false;
      }
    } catch (e) {
      PopupService.showErrorPopup(context, e.toString());
      _isLoading = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /////////////////////////////////  POPUPS ///////////////////////////////
  Future<void> checkNextClassPopup(
    BuildContext context,
    Package package,
  ) async {
    print('selectedPackage $selectedPackage');
    print('startDate $startDate');
    print('endDate $endDate');
    if (startDate == null || endDate == null || package == null) return;

    final nextClass = scheduleProvider.getNextClassDateAfterEnd(
      endDate: endDate!,
      subject: package.subject,
    );
    print("nextClass ===>>> $nextClass");

    /// CASE 2 — Regular student
    await PopupService.showNextClassInfoPopup(
      context,
      nextClass!,
      onNo: () {
        endDate = null;
        notifyListeners();
      },
      onYes: () {
        // Navigator.pop(context);
      },
    );
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
              backgroundColor: Colors.white,
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
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                  ),
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
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  /////////////////////////////////  POPUPS ///////////////////////////////

  ///////////////////////////////// Dates in  Shared pref  ///////////////////////////////
  Future<List<Map<String, dynamic>>> _getPreviousRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('freezingRequests') ?? [];
    return existing.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

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
  ///////////////////////////////// Dates in  Shared pref  ///////////////////////////////

  DateTime getNextMonday(DateTime date) {
    int daysToAdd = (DateTime.monday - date.weekday) % 7;
    if (daysToAdd == 0) {
      daysToAdd = 7; // if already Monday → next Monday
    }
    return date.add(Duration(days: daysToAdd));
  }

  /// GET season api and packages api
  Future<void> fetchSeasons() async {
    _isLoadingforSeason = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConfigService.endpoints.freezingSeasons),
        headers: {
          "Content-Type": "application/json",
          "api-key": "60e35fdc-401d-494d-9d78-39b15e345547",
        },
      );
      print('response.fetchSeasons ${response.statusCode}');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        seasons = data.map((e) => FreezingSeason.fromJson(e)).toList();
        print('seasons ${seasons}');
      }
    } catch (e) {
      print("Season error: $e");
    }

    _isLoadingforSeason = false;
    notifyListeners();
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
              PopupService.showNotCustomerDialog(navigatorKey.currentContext!);
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
}
