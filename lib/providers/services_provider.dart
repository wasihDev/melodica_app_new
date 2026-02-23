import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/dance_and_piano_model.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/models/student_models.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/download_pdf.dart';
import 'package:melodica_app_new/widgets/custom_recipet_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'dart:math';

enum PaymentType {
  packagesOrder,
  freezingPoints,
  schedulePoints,
  scheduleExpiry,
}

class ServicesProvider extends ChangeNotifier {
  CustomerController customerController;

  ServicesProvider({required this.customerController});
  SignatureController _signratureCtrl = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  PaymentType? currentPaymentType;

  void setPaymentType(PaymentType type) {
    currentPaymentType = type;
  }

  Uint8List? signatureBytes;
  SignatureController get signratureCtrl => _signratureCtrl;
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<ServiceModel> _all = [];
  List<ServiceModel> get all => _all;

  List<ServiceModel> _alldanceList = [];
  List<ServiceModel> get alldanceList => List.unmodifiable(_alldanceList);
  // UI state
  String _tab = 'Music'; // or 'Dance'
  String get tab => _tab;

  String? _selectedServiceName; // e.g., "Piano Private Class"
  int? _selectedDuration; // e.g., 30
  String? _selectedPriceId; // selected package priceid

  String? get selectedServiceName => _selectedServiceName;
  int? get selectedDuration => _selectedDuration;
  String? get selectedPriceId => _selectedPriceId;
  List<SelectedPackageItem> _selectedPackages = [];
  bool _initialized = false;

  List<SelectedPackageItem> get selectedPackages =>
      List.unmodifiable(_selectedPackages);
  final AppLinks _appLinks = AppLinks();
  final List<ServiceModel> _selectedPackagesTemp = [];

  List<ServiceModel> get selectedPackagesTemp =>
      List.unmodifiable(_selectedPackagesTemp);

  /// Call ONCE
  void init(BuildContext context) {
    if (_initialized) return;
    _initialized = true;

    // Cold start
    _appLinks.getInitialLink().then((uri) => _handleUri(uri, context));

    // Foreground / background
    _appLinks.uriLinkStream.listen((uri) => _handleUri(uri, context));
  }

  void _handleUri(Uri? uri, BuildContext context) async {
    debugPrint('Incoming URI: $uri');
    if (uri == null) return;

    // 1. Updated Guard: Allow either the HTTPS website OR the custom 'melodica' scheme
    bool isWebLink =
        uri.scheme == 'https' && uri.host == 'melodica-mobile.web.app';
    bool isCustomScheme = uri.scheme == 'melodica';

    if (!isWebLink && !isCustomScheme) {
      debugPrint('Link rejected: Invalid scheme or host');
      return;
    }

    // 2. Extract the 'ref' parameter (works for both https://... and melodica://...)
    final ref = uri.queryParameters['ref'];
    debugPrint('Query Parameters: ${uri.queryParameters}');

    if (ref == null || ref.isEmpty) {
      debugPrint('Link rejected: No ref parameter found');
      return;
    }
    switch (currentPaymentType) {
      case PaymentType.freezingPoints:
        debugPrint('Handling freezing points');

        final provider = Provider.of<PackageProvider>(
          navigatorKey.currentContext!,
          listen: false,
        );
        print("provider.selectedReason ${provider.selectedReason}");
        print("provider.selectedPackage ${provider.selectedPackage}");
        if (provider.selectedPackage != null &&
            provider.selectedReason != null) {
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) => CustomRecipetScreen(
                orderId: ref,
                amount: provider.extraCharge.toString(),
                paymentMethod: 'Network International',
                status: 'success',
                date: DateTime.now(),
                isSchedule: false,
                //  package: Package,
              ),
            ),
          );
          // await provider
          //     .callFreezingApi(
          //       navigatorKey.currentContext!,
          //       provider.selectedReason!,
          //       provider.selectedPackage!,
          //       ref: ref, // ✅ payment reference
          //     )
          //     .then((val) {

          //     });
        }

        break;

      case PaymentType.schedulePoints:
        debugPrint('Handling schedule points');
        final Packageprovider = Provider.of<ScheduleProvider>(
          navigatorKey.currentContext!,
          listen: false,
        );
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (_) => CustomRecipetScreen(
              orderId: ref,
              amount: "${Packageprovider.totalamount}",
              paymentMethod: 'Network International',
              status: 'success',
              date: DateTime.now(),
              isSchedule: true,
            ),
          ),
        );

        // navigate to schedule receipt if needed
        break;

      case PaymentType.packagesOrder:
        debugPrint('Installing order');

        try {
          // final val = await installOrder(ref: ref);
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (_) => ThankYouScreen()),
          );
        } catch (e) {
          debugPrint('Error processing order: $e');
        }
        break;

      default:
        debugPrint('Unknown payment type — ignoring');
    }

    // ✅ ALWAYS reset after handling
    currentPaymentType = null;
  }

  void clearList() {
    isStudentNew = false;
    _selectedPackages = [];
    notifyListeners();
  }

  /// Add package (prevent duplicates)
  // void addPackage(Ser package, int index) {
  //   if (_selectedPackages.any((e) => e.priceId == package.priceId)) {
  //     _selectedPackages.remove(package);
  //   } else {
  //     _selectedPackages.add(package);
  //   }
  //   notifyListeners();
  // }
  void addPackageForStudent(ServiceModel package, Student student) {
    final exists = _selectedPackages.any(
      (e) =>
          e.package.priceId == package.priceId &&
          e.student.mbId == student.mbId,
    );

    if (exists) {
      // Optional: show message
      debugPrint("Package already added for this student");
      return;
    }

    _selectedPackages.add(
      SelectedPackageItem(package: package, student: student),
    );

    notifyListeners();
  }

  bool isSelected(ServiceModel package) {
    return _selectedPackagesTemp.any((e) => e.priceId == package.priceId);
  }

  //// add packages for dance///
  ////
  void togglePackageSelection(ServiceModel package) {
    final exists = _selectedPackagesTemp.any(
      (e) => e.priceId == package.priceId,
    );

    if (exists) {
      _selectedPackagesTemp.removeWhere((e) => e.priceId == package.priceId);
    } else {
      _selectedPackagesTemp.add(package);
    }

    notifyListeners();
  }

  void removeSelectpackageSelection() {
    _selectedPackagesTemp.clear();
    notifyListeners();
  }

  //////
  /// Remove package
  // void removePackage(ServiceModel package) {
  //   _selectedPackages.removeWhere((e) => e.priceId == package.priceId);
  //   notifyListeners();
  // }
  void removePackageAt(int index) {
    _selectedPackages.removeAt(index);
    notifyListeners();
  }

  /// Clear checkout
  void clear() {
    isStudentNew = false;
    // val.split('.').last
    _selectedPackages.clear();
    notifyListeners();
  }

  // static const double  = 0.10; // 10%
  static const double vatRate = 0.05; // 5%

  /// TOTAL PRICE
  double get totalPrice {
    return _selectedPackages.fold(0.0, (sum, item) => sum + item.package.price);
  }

  /// TOTAL DISCOUNT (10%)
  double get totalDiscount {
    return _selectedPackages.fold(0.0, (sum, item) {
      final discountPercent = item.package.discount;
      final discountAmount = item.package.price * (discountPercent / 100);
      // print('discountAmount ${discountAmount}');
      return sum + discountAmount;
    });
  }

  /// VAT AMOUNT (5%)
  double get vatAmount {
    double subtotal = totalPrice - totalDiscount;
    if (_isStudentNew) {
      subtotal += 150.0;
    }
    return subtotal * vatRate;
  }

  /// FINAL AMOUNT (Including VAT)
  double get payableAmount {
    return (totalPrice - totalDiscount) + vatAmount;
  }

  bool _isStudentNew = false;

  /// Getter
  bool get isStudentNew => _isStudentNew;

  /// Setter
  set isStudentNew(bool value) {
    _isStudentNew = value;
    notifyListeners();
  }

  Map<String, List<SelectedPackageItem>> get packagesGroupedByStudent {
    final Map<String, List<SelectedPackageItem>> grouped = {};

    for (var item in _selectedPackages) {
      final studentId = item.student.fullName.toString(); // 🔴 force String
      print('studentId ====>>> $studentId');
      grouped.putIfAbsent(studentId, () => []).add(item);
    }

    return grouped;
  }

  // music list package
  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();
    // final auth = FirebaseAuth.instance.currentUser;
    try {
      final uri = Uri.parse(
        // '${ApiConfigService.endpoints.getServices}${auth?.email}',
        '${ApiConfigService.endpoints.getServices}${customerController.selectedBranch}',
      );

      final resp = await http.get(
        uri,
        headers: {'api-key': "60e35fdc-401d-494d-9d78-39b15e345547"},
      );
      print('resp.statusCode ${resp.statusCode}');
      if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
      final Map<String, dynamic> body =
          json.decode(resp.body) as Map<String, dynamic>;
      // print('body ');
      final List<dynamic>? arr = body['services'] as List<dynamic>?;
      print('arr  ${arr}');
      if (arr == null) {
        _all = [];
        // print('_all1 $_all ');
        _error = 'No services key in response';
      } else {
        _all = arr
            .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // print('_all2 ${_all.map((e) => e.price)} ');
        // set defaults if nothing selected
        if (_selectedServiceName == null && _all.isNotEmpty) {
          _selectedServiceName = _all.first.serviceName;
          print('_selectedServiceName ${_selectedServiceName} ');
          notifyListeners();
        }
        if (_selectedDuration == null && _all.isNotEmpty) {
          // pick the first duration available for selected service
          final durations = _getDurationsForService(_selectedServiceName);
          if (durations.isNotEmpty) _selectedDuration = durations.first;
          print('_selectedDuration ${_selectedDuration} ');
          notifyListeners();
        }
      }
      print('end main');
    } catch (e) {
      print('eror $e');
      _error = 'Failed to fetch: $e';
      _all = [];
    } finally {
      print('finallnu call');
      _loading = false;
      notifyListeners();
    }
  }

  // void removePackageAt(int index) {
  //   _selectedPackages.removeAt(index);
  //   notifyListeners();
  // }

  // dance list package
  Future<void> fetchDancePackages() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final uri = Uri.parse(
        '${ApiConfigService.endpoints.getMemberships}${customerController.selectedBranch}',
      );
      final resp = await http.get(
        uri,
        headers: {'api-key': "60e35fdc-401d-494d-9d78-39b15e345547"},
      );
      // print("resp fetchDancePackages ${resp.statusCode}");
      // print("resp fetchDancePackages ${resp.body.length}");
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }

      final Map<String, dynamic> body =
          json.decode(resp.body) as Map<String, dynamic>;
      final List<dynamic>? arr = body['services'] as List<dynamic>?;

      _alldanceList.clear();
      if (arr != null) {
        // _alldanceList.addAll(
        //   arr.map((e) => DanceDataModel.fromJson(e as Map<String, dynamic>)),
        // );
        _alldanceList = arr
            .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _alldanceList = [];
        // SnackbarUtils.showError(context, "N")
      }
    } catch (e) {
      _error = 'Failed to fetch: $e';
      _alldanceList.clear();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // change tab (Music/Dance) — kept for UI but doesn't filter data in this example
  void setTab(String t) {
    _tab = t;
    notifyListeners();
  }

  // service dropdown changed
  void setSelectedService(String serviceName) {
    _selectedServiceName = serviceName;
    // update duration default when service changes
    final durations = _getDurationsForService(serviceName);
    _selectedDuration = durations.isNotEmpty ? durations.first : null;
    _selectedPriceId = null;
    notifyListeners();
  }

  String get selectedProductNames {
    final selected = _all.where((e) => e.priceId == _selectedPriceId).toList();

    return selected.map((e) => e.packageName).join(', ');
  }

  // duration buttons
  void setSelectedDuration(int duration) {
    _selectedDuration = duration;
    _selectedPriceId = null;
    notifyListeners();
  }

  // select a package (by price id)
  void selectPrice(String priceId) {
    _selectedPriceId = priceId;

    print('_selectedPriceId $_selectedPriceId ');
    print('priceId $priceId ');
    notifyListeners();
  }

  // helper getters to produce lists for UI
  List<String> get uniqueServices {
    final set = <String>{};
    for (var s in _all) set.add(s.serviceName);
    return set.toList();
  }

  List<int> _getDurationsForService(String? serviceName) {
    if (serviceName == null) return [];
    final set = <int>{};
    for (var s in _all) {
      if (s.serviceName == serviceName) set.add(s.duration);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<int> get durationsForSelectedService =>
      _getDurationsForService(_selectedServiceName);

  List<ServiceModel> get filteredList {
    final filtered = _all.where((s) {
      final okService = _selectedServiceName == null
          ? true
          : s.serviceName == _selectedServiceName;

      final okDuration = _selectedDuration == null
          ? true
          : s.duration == _selectedDuration;

      final okFrequency = _selectedFrequency == null
          ? true
          : mapFrequencyText(s.frequencyText) == _selectedFrequency;

      return okService && okDuration && okFrequency;
    });

    final seen = <String>{};

    return filtered.where((s) {
      final key =
          '${s.sessions}_${s.duration}_${s.serviceName}_${s.frequencyText}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  // frequency
  String mapFrequencyText(String apiValue) {
    switch (apiValue.toLowerCase()) {
      case '1 x week':
        return 'Once a week';
      case '2 x week':
        return 'Twice a week';
      default:
        return apiValue;
    }
  }

  String? _selectedFrequency =
      'Once a week'; // UI value: Once a week / Twice a week
  String? get selectedFrequency => _selectedFrequency;

  void setFrequency(String? value) {
    _selectedFrequency = value;
    notifyListeners();
  }

  List<String> get frequencyOptions {
    final set = <String>{};

    for (final s in _all) {
      set.add(mapFrequencyText(s.frequencyText));
    }

    return set.toList();
  }

  // clear selection
  void clearSelection() {
    _selectedPriceId = null;
    notifyListeners();
  }

  void clearPaymentData() {
    _paymentUrl = null;
    _orderReference = null;
    _orderId = null;
    notifyListeners();
  }

  String? _paymentUrl;
  String? get paymentUrl => _paymentUrl;
  String? _orderReference;
  String? get orderReference => _orderReference;
  String? _orderId;
  String? get orderId => _orderId;

  Future<bool> startCheckout(
    BuildContext context, {
    // required String branchId,
    required num amount, // major units (10.0)
  }) async {
    clearPaymentData();

    showLoadingDialog(context);
    print('amount ${customerController.selectedBranch}');
    print('amoutn2 ${amount}');

    try {
      final response = await http.post(
        Uri.parse(ApiConfigService.endpoints.collectPayment),
        headers: {
          "Content-Type": "application/json",
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },
        body: jsonEncode({
          "branch": "${customerController.selectedBranch}",
          "amount": amount,
        }),
      );
      //4950 total
      // after discount 3712.5
      // after 4950 + 5% = 5197.5
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _paymentUrl = data["URL"];
        _orderReference = data["merchantOrderReference"];
        _orderId = data['ID'];
        notifyListeners();
        return true;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print('paymenr error $e');
      _error = e.toString();
      return false;
    } finally {
      hideLoadingDialog(context);
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
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

  final Random _random = Random();
  int _randomNumber = 0;

  int get randomNumber => _randomNumber;

  void generateRandom() {
    _randomNumber = _random.nextInt(100);
    notifyListeners();
  } // post api install package

  Future<bool> installOrder({required String checkOutScreenBase64}) async {
    // if (_selectedPackages.isEmpty) return false;
    _setLoading(true);

    showLoadingDialog(navigatorKey.currentContext!);
    generateRandom();
    final signatureBase64 = base64Encode(signatureBytes!);
    try {
      final url = ApiConfigService.endpoints.installPackage;
      print('_orderReference ${_orderReference}');
      print('signatureBase64 $signatureBase64');
      // var isAdmissionAdded = false;

      final body = {
        "firstname": customerController.customer?.firstName,
        "lastname": customerController.customer?.lastName,
        "relatedcontact":
            "${customerController.students.map((e) => e.mbId).join(",")}",
        "branch": "${customerController.selectedBranch}",
        "email": "${FirebaseAuth.instance.currentUser?.email ?? ""}",
        "transactionid": "$_orderId", // empty
        "salesid": "$_orderReference", //merchantOrderReference
        "paymentdate": "${DateTime.now().toIso8601String().split('T').first}",
        "paymenturl": "APP", // get this from network international
        "paymentmethod": "Network International",
        "orderdetails": _selectedPackages.asMap().entries.map((entry) {
          int index = entry.key; // Get the current index
          var item = entry.value;
          var e = item.package;
          var student = item.student;

          final bool isFirstItem = index == 0;
          final bool chargeAdmission =
              isFirstItem &&
              (_isStudentNew == true || student.isregistred != 'Yes');
          final bool displayNewDetails =
              (_isStudentNew == true || student.isregistred != 'Yes');
          print('chargeAdmission $chargeAdmission');
          final double admissionValue = chargeAdmission ? 150.0 : 0.0;
          final double discountPercent =
              (double.tryParse(e.discount.toString().replaceAll('%', '')) ??
                  0.0) /
              100;

          // Calculate Subtotal and Discount Amount
          final double baseAmount = e.price + admissionValue;
          final double discountAmount = baseAmount * discountPercent;
          final double discountedSubtotal = baseAmount - discountAmount;
          print('discountedSubtotal $discountedSubtotal');
          // 4. Calculate VAT (5%) on the Discounted Subtotal
          final double vatValue = discountedSubtotal * 0.05;
          print('vatValue $vatValue');
          final double totalValue = discountedSubtotal + vatValue;
          print('totalValue $totalValue');

          return {
            "priceid": "${e.priceId}",
            "type": "${_tab}", // Ensure this is "Dance" or "Music"
            "studentid": displayNewDetails ? "" : "${student.mbId}",
            "studentname": displayNewDetails
                ? "${customerController.firstNameCtrl.text == "" ? student.firstName : customerController.firstNameCtrl.text}"
                : student.firstName,
            "studentlastname": displayNewDetails
                ? "${customerController.lastNameCtrl.text == "" ? student.lastName : customerController.lastNameCtrl.text}"
                : student.lastName,
            "details": "${e.packageName}",
            "coupon": "",
            "admission": chargeAdmission ? "150" : "",
            "discount": "${e.discount}",
            "amount": "${e.price.toStringAsFixed(2)}",
            "vat": "${vatValue.toStringAsFixed(2)}",
            "total": "${totalValue}",
          };
        }).toList(),
        "checkoutscreen": "$checkOutScreenBase64",
        "signature": "$signatureBase64",
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },

        body: jsonEncode(body),
      );
      print('response ===>> ${response.statusCode}');
      print("API BODY:");
      dev.log(const JsonEncoder.withIndent('  ').convert(body));

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }
      print('response2 ===>> ${response.body}');
      // _selectedPackages.clear();
      hideLoadingDialog(navigatorKey.currentContext!);

      _setLoading(false);
      return true;
    } catch (e) {
      print('errpr $e');
      hideLoadingDialog(navigatorKey.currentContext!);
      _setLoading(false);
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
