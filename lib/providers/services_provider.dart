import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/dance_data_model.dart';
import 'package:melodica_app_new/models/services_model.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/download_pdf.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/receipt_screen.dart';
import 'package:melodica_app_new/widgets/custom_recipet_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'dart:math';

// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
enum PaymentType {
  packagesOrder,
  freezingPoints,
  schedulePoints,
  scheduleExpiry,
}

class ServicesProvider extends ChangeNotifier {
  CustomerController customerController;
  // PackageProvider packageProvider;

  ServicesProvider({
    required this.customerController,
    // required this.packageProvider,
  });
  // final AppLinks _appLinks = AppLinks();
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
  // Uint8List get signatureBytes => _signatureBytes!;
  SignatureController get signratureCtrl => _signratureCtrl;
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<ServiceModel> _all = [];
  List<ServiceModel> get all => _all;

  List<DanceDataModel> _alldanceList = [];
  List<DanceDataModel> get alldanceList => List.unmodifiable(_alldanceList);
  // UI state
  String _tab = 'Music'; // or 'Dance'
  String get tab => _tab;

  String? _selectedServiceName; // e.g., "Piano Private Class"
  int? _selectedDuration; // e.g., 30
  String? _selectedPriceId; // selected package priceid

  String? get selectedServiceName => _selectedServiceName;
  int? get selectedDuration => _selectedDuration;
  String? get selectedPriceId => _selectedPriceId;
  List<dynamic> _selectedPackages = [];
  bool _initialized = false;

  List<dynamic> get selectedPackages => List.unmodifiable(_selectedPackages);
  final AppLinks _appLinks = AppLinks();
  // bool _initialized = false;
  // bool _linkHandled = false;

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

        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (_) => CustomRecipetScreen(
              orderId: ref,
              amount: provider.extraCharge.toString(),
              paymentMethod: 'Network International',
              status: 'success',
              date: DateTime.now(),
            ),
          ),
        );
        break;

      case PaymentType.schedulePoints:
        debugPrint('Handling schedule points');
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (_) => CustomRecipetScreen(
              orderId: ref,
              amount: "${50 * 1.05}",
              paymentMethod: 'Network International',
              status: 'success',
              date: DateTime.now(),
            ),
          ),
        );
        // navigate to schedule receipt if needed
        break;

      case PaymentType.packagesOrder:
        debugPrint('Installing order');

        try {
          final val = await installOrder(ref: ref);
          if (val) {
            Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (_) => ThankYouScreen()),
            );
          }
        } catch (e) {
          debugPrint('Error processing order: $e');
        }
        break;

      default:
        debugPrint('Unknown payment type — ignoring');
    }

    // ✅ ALWAYS reset after handling
    currentPaymentType = null;

    // if (currentPaymentType != PaymentType.freezingPoints) {
    //   final provider = Provider.of<PackageProvider>(
    //     navigatorKey.currentContext!,
    //     listen: false,
    //   );
    //   Navigator.push(
    //     navigatorKey.currentContext!,
    //     MaterialPageRoute(
    //       builder: (_) => CustomRecipetScreen(
    //         orderId: '$ref',
    //         amount: provider.extraCharge.toString(),
    //         paymentMethod: 'Network International',
    //         status: 'success',
    //         date: DateTime.now(),
    //       ),
    //     ),
    //   );
    //   debugPrint('freezingPoints');
    //   return;
    // } else if (currentPaymentType != PaymentType.schedulePoints) {
    //   // Navigator.push(
    //   //   navigatorKey.currentContext!,
    //   //   MaterialPageRoute(builder: (_) => ReceiptScreen()),
    //   // );
    //   debugPrint('schedulePoints');
    //   return;
    // } else {
    //   // 3. Process the Payment / Order
    //   try {
    //     debugPrint('install order');
    //     final val = await installOrder(ref: ref);
    //     if (val) {
    //       // Use the navigatorKey to ensure we have the right context
    //       Navigator.push(
    //         navigatorKey.currentContext!,
    //         MaterialPageRoute(builder: (_) => ReceiptScreen()),
    //       );
    //     }
    //   } catch (e) {
    //     debugPrint('Error processing order: $e');
    //   }
    // }
  }

  // void _handleUri(Uri? uri, BuildContext context) async {
  //   // if (_linkHandled) return; // 🔐 BLOCK SECOND CALL
  //   // _linkHandled = true;
  //   debugPrint('uri =====>>> $uri');
  //   if (uri == null) return;
  //   if (uri.scheme != 'https' || uri.host != 'melodica-mobile.web.app') return;
  //   final ref = uri.queryParameters['ref'];
  //   // final type = uri.queryParameters['type']; // 👈 NEW
  //   // print('type ${type}');
  //   print('uri.queryParameters ${uri.queryParameters}');
  //   if (ref == null || ref.isEmpty) return;
  //   /// Delegate to ServicesProvider
  //   if (uri.scheme == 'https' && uri.host == 'melodica-mobile.web.app') {
  //     final ref = uri.queryParameters['ref'];
  //     if (ref != null && ref.isNotEmpty) {
  //       final val = await installOrder(ref: ref);
  //       if (val) {
  //         Navigator.push(
  //           navigatorKey.currentContext!,
  //           MaterialPageRoute(builder: (_) => ReceiptScreen()),
  //         );
  //       }
  //       // if the install order is called true navigate to recieot screen
  //     }
  //   }
  // }

  void clearList() {
    _selectedPackages = [];
    notifyListeners();
  }

  /// Add package (prevent duplicates)
  void addPackage(dynamic package, int index) {
    if (_selectedPackages.any((e) => e.priceid == package.priceid)) {
      _selectedPackages.remove(package);
    } else {
      _selectedPackages.add(package);
    }

    notifyListeners();
  }

  bool isSelected(dynamic package) {
    return _selectedPackages.any((e) => e.priceid == package.priceid);
  }

  //// add packages for dance///
  ////

  //////
  /// Remove package
  void removePackage(ServiceModel package) {
    _selectedPackages.removeWhere((e) => e.priceid == package.priceid);
    notifyListeners();
  }

  /// Clear checkout
  void clear() {
    _selectedPackages.clear();
    notifyListeners();
  }

  // static const double  = 0.10; // 10%
  static const double vatRate = 0.05; // 5%

  /// TOTAL PRICE
  double get totalPrice {
    return _selectedPackages.fold(0.0, (sum, item) => sum + item.price);
  }

  /// TOTAL DISCOUNT (10%)
  double get totalDiscount {
    return _selectedPackages.fold(0.0, (sum, item) {
      final discountPercent = double.tryParse(item.discount ?? '0') ?? 0.0;
      final discountAmount = item.price * (discountPercent / 100);
      return discountAmount;
    });
  }

  /// VAT AMOUNT (5%)
  double get vatAmount {
    final subtotal = totalPrice - totalDiscount;
    return subtotal * vatRate;
  }

  /// FINAL AMOUNT (Including VAT)
  double get payableAmount {
    return (totalPrice - totalDiscount) + vatAmount;
  }

  // /// TOTAL PRICE
  // double get totalPrice {
  //   return _selectedPackages.fold(0, (sum, item) => sum + item.price);
  // }

  // // /// TOTAL DISCOUNT

  // double get totalDiscount {
  //   return _selectedPackages.fold(
  //     0.0,
  //     (sum, item) => sum + (double.tryParse(item.discount ?? '0') ?? 0.0),
  //   );
  // }

  // // return totalPrice - totalDiscount + vat;

  // /// FINAL AMOUNT
  // double get payableAmount {
  //   return totalPrice - totalDiscount;
  // }

  // music list package
  Future<void> fetch(String terrirtoryId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        '${ApiConfigService.endpoints.getServices}${terrirtoryId}',
      );

      final resp = await http.get(uri);
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
          _selectedServiceName = _all.first.service;
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

  void removePackageAt(int index) {
    _selectedPackages.removeAt(index);
    notifyListeners();
  }

  // dance list package
  Future<void> fetchDancePackages() async {
    _loading = true;
    _error = null;
    notifyListeners();
    print(
      "${ApiConfigService.endpoints.getMemberships}${customerController.customer!.territoryid}",
    );
    try {
      final uri = Uri.parse(
        '${ApiConfigService.endpoints.getMemberships}${customerController.customer!.territoryid}',
        //C27B1894-7C6E-EE11-9AE7-0022489F8146',
        // 'https://bf67c0337b6de47faeee4735e1fe49.46.environment.api.powerplatform.com/powerautomate/automations/direct/workflows/19d12f88493c44eca47defb553aab05e/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=adzRWIXbH-lg5lnxWCNgD-w9SbvgQ0zgnqIrAWQADo8&locationid=C27B1894-7C6E-EE11-9AE7-0022489F8146',
      );
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }

      final Map<String, dynamic> body =
          json.decode(resp.body) as Map<String, dynamic>;
      final List<dynamic>? arr = body['services'] as List<dynamic>?;

      _alldanceList.clear();
      if (arr != null) {
        _alldanceList.addAll(
          arr.map((e) => DanceDataModel.fromJson(e as Map<String, dynamic>)),
        );
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
    final selected = _all.where((e) => e.priceid == _selectedPriceId).toList();

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
    for (var s in _all) set.add(s.service);
    return set.toList();
  }

  List<int> _getDurationsForService(String? serviceName) {
    if (serviceName == null) return [];
    final set = <int>{};
    for (var s in _all) {
      if (s.service == serviceName) set.add(s.duration);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<int> get durationsForSelectedService =>
      _getDurationsForService(_selectedServiceName);

  // List<ServiceModel> get filteredList {
  //   return _all.where((s) {
  //     final okService = _selectedServiceName == null
  //         ? true
  //         : s.service == _selectedServiceName;
  //     final okDuration = _selectedDuration == null
  //         ? true
  //         : s.duration == _selectedDuration;
  //     return okService && okDuration;
  //   }).toList();
  // }
  // List<ServiceModel> get filteredList {
  //   final filtered = _all.where((s) {
  //     final okService = _selectedServiceName == null
  //         ? true
  //         : s.service == _selectedServiceName;
  //     final okDuration = _selectedDuration == null
  //         ? true
  //         : s.duration == _selectedDuration;
  //     return okService && okDuration;
  //   });

  //   final seen = <String>{};

  //   return filtered.where((s) {
  //     final key = '${s.sessions}_${s.duration}_${s.service}';
  //     if (seen.contains(key)) return false;
  //     seen.add(key);
  //     return true;
  //   }).toList();
  // }

  List<ServiceModel> get filteredList {
    final filtered = _all.where((s) {
      final okService = _selectedServiceName == null
          ? true
          : s.service == _selectedServiceName;

      final okDuration = _selectedDuration == null
          ? true
          : s.duration == _selectedDuration;

      final okFrequency = _selectedFrequency == null
          ? true
          : mapFrequencyText(s.frequencytext) == _selectedFrequency;

      return okService && okDuration && okFrequency;
    });

    final seen = <String>{};

    return filtered.where((s) {
      final key = '${s.sessions}_${s.duration}_${s.service}_${s.frequencytext}';
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

  String? _selectedFrequency; // UI value: Once a week / Twice a week
  String? get selectedFrequency => _selectedFrequency;

  void setFrequency(String? value) {
    _selectedFrequency = value;
    notifyListeners();
  }

  List<String> get frequencyOptions {
    final set = <String>{};

    for (final s in _all) {
      set.add(mapFrequencyText(s.frequencytext));
    }

    return set.toList();
  }

  // clear selection
  void clearSelection() {
    _selectedPriceId = null;
    notifyListeners();
  }

  String? _paymentUrl;
  String? get paymentUrl => _paymentUrl;
  String? _orderReference;
  String? get orderReference => _orderReference;

  // Future<void> collectPayment({required num amount}) async {
  //   _loading = true;
  //   _error = null;
  //   notifyListeners();
  //   try {
  //     final response = await http.post(
  //       Uri.parse(ApiConfigService.endpoints.collectPayment),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "branch": customerController.customer!.territoryid,
  //         "amount": amount,
  //       }),
  //     );
  //     if (response.statusCode != 200) {
  //       throw Exception(response.body);
  //     }
  //     final data = jsonDecode(response.body);
  //     _paymentUrl = data["URL"];
  //     _orderReference = data["merchantOrderReference"];
  //     /// 🔥 Open payment page immediately
  //     await _openPaymentUrl(_paymentUrl!);
  //   } catch (e) {
  //     _error = e.toString();
  //   } finally {
  //     _loading = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> _openPaymentUrl(String url) async {
  //   final uri = Uri.parse(url);
  //   if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
  //     throw Exception("Could not open payment page");
  //   }
  // }

  Future<String?> _getAccessToken() async {
    try {
      const apiKey =
          'M2Q4M2JiOWQtNWI3Ni00OGNjLTk1NWEtZDUyYWI3M2M0ZTFhOjVmZjg5MzY0LThiMjEtNGYyYi1hY2E3LTg4ZWYzMjJjYWM4Yw==';

      final response = await http.post(
        Uri.parse(
          "https://api-gateway.sandbox.ngenius-payments.com/identity/auth/access-token",
        ),
        headers: {
          "Content-Type": "application/vnd.ni-identity.v1+json",
          "Authorization": "Basic $apiKey",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["access_token"];
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  /// Converts a double amount in major units to an integer amount in minor units.
  ///
  /// For example, if the amount is 10.00, this function will return 1000.
  ///
  /// @param amount The amount in major units.
  /// @return The amount in minor units.
  int toMinorUnits(double amount) {
    return (amount * 100).toInt();
  }

  Future<bool> startCheckout(
    BuildContext context, {
    required int amount, // e.g. 1000 = 10.00 AED
    required String redirectUrl,
  }) async {
    showLoadingDialog(context);
    print('amount $amount');
    print('redirectUrl $redirectUrl');
    try {
      final token = await _getAccessToken();
      if (token == null) return false;

      const outletId = "f05267d0-5b94-438a-a839-992702929316";

      final response = await http.post(
        Uri.parse(
          "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/$outletId/orders",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/vnd.ni-payment.v2+json",
          "Accept": "application/vnd.ni-payment.v2+json",
        },
        body: jsonEncode({
          "action": "SALE",
          "amount": {
            "currencyCode": "AED",
            "value":
                //10,
                toMinorUnits(amount.toDouble()),
          },
          "merchantAttributes": {"redirectUrl": redirectUrl},
        }),
      );
      print('status ${response.statusCode}');
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _paymentUrl = data["_links"]["payment"]["href"];
        print('_paymentUrl ${_paymentUrl}');

        return true;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print('error $e');
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

  Future<bool> installOrder({required String ref}) async {
    // if (_selectedPackages.isEmpty) return false;
    _setLoading(true);

    showLoadingDialog(navigatorKey.currentContext!);
    generateRandom();

    try {
      final url = ApiConfigService.endpoints.installPackage;

      final body = {
        "firstname": customerController.customer?.firstName,
        "lastname": customerController.customer?.lastName,
        "relatedcontact":
            "${customerController.students.map((e) => e.mbId).join(",")}",
        "branch": "${customerController.customer?.territoryid}",
        "transactionid":
            "$ref", // after payment is completed the refrence id should be here
        "salesid": "$randomNumber",
        "paymentdate": "${DateTime.now().toIso8601String().split('T').first}",
        "paymenturl": "APP", // get this from network international
        "paymentmethod": "Network International",
        "orderdetails": _selectedPackages.map((e) {
          final vat = (e.price * 0.05);
          final total = e.price + vat;

          return {
            "priceid": "${e.priceid}",
            "type": "${_tab}", // Music or Dance
            "studentid": "${customerController.selectedStudent?.mbId}",
            "studentname": customerController.selectedStudent?.firstName,
            "studentlastname": customerController.selectedStudent?.lastName,
            "details": e.packageName,
            "coupon": "",
            "admission": "", //leave it blank if already registered
            "discount": "${e.discount}",
            "amount": "${e.price.toStringAsFixed(2)}",
            "vat": "${vat.toStringAsFixed(2)}",
            "total": "${total.toStringAsFixed(2)}",
          };
        }).toList(),
        "orderpdf": ref,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      print('response ===>> ${response.statusCode}');
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
