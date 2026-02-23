import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/country_codes.dart';
import 'package:melodica_app_new/models/student_models.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:melodica_app_new/views/dashboard/home/faq/help_center.dart';
import 'package:melodica_app_new/views/dashboard/notification/services/notification_service.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomerController extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;
  bool _display = false;

  Customer? _customer;
  Customer? get customer => _customer;

  List<Student> _students = [];
  List<Student> get students => _students;

  Student? _selectedStudent;
  Student? get selectedStudent => _selectedStudent;
  bool get display => _display;
  List<String> _isShowData = [];
  List<String> get isShowData => _isShowData;
  // ================= TEXT CONTROLLERS =================
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  // ================= FORM STATE =================
  String _selectedGender = '';
  String _selectedRelation = '';
  String _selectedLevel = '';
  bool? _isMelodicaStudent = true;

  // ================= GETTERS =================
  String get selectedGender => _selectedGender;
  String get selectedRelation => _selectedRelation;
  String get selectedLevel => _selectedLevel;
  bool? get isMelodicaStudent => _isMelodicaStudent;

  // ================= SETTERS =================
  void setGender(String value) {
    _selectedGender = value;
    notifyListeners();
  }

  void setRelation(String value) {
    _selectedRelation = value;
    notifyListeners();
  }

  void setLevel(String value) {
    _selectedLevel = value;
    notifyListeners();
  }

  void setIsMelodicaStudent(bool value) {
    _isMelodicaStudent = value;
    notifyListeners();
  }

  // ================= VALIDATION =================
  bool get isStudentFormValid {
    return firstNameCtrl.text.isNotEmpty &&
        lastNameCtrl.text.isNotEmpty &&
        emailCtrl.text.isNotEmpty &&
        phoneCtrl.text.isNotEmpty &&
        _selectedGender.isNotEmpty &&
        _selectedRelation.isNotEmpty &&
        _selectedLevel.isNotEmpty;
  }

  // ================= RESET =================
  void clearStudentForm() {
    firstNameCtrl.clear();
    lastNameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    _selectedGender = '';
    _selectedRelation = '';
    _selectedLevel = '';
    _isMelodicaStudent = true;
    print('-----------------Clear Student form--------------');
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> getDisplayDance(String territoryid) async {
    _loading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        ApiConfigService.endpoints.displayDance,
        // 'https://bf67c0337b6de47faeee4735e1fe49.46.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/c6a709829bfc45b6...',
      );
      print("territoryid in funtion ${customer!.territoryid}");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },

        body: jsonEncode({'locationid': "$territoryid"}),
        // customer?.territoryid}),
      );
      print("get disaplay dance ${response.statusCode} ");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("get disaplay data ${data} ");

        _display = data['display'] == true;
        print('display $_display');
      } else {
        _display = false;
      }
      notifyListeners();
    } catch (e) {
      print('errror getDisPlay $e');
      _display = false;
    } finally {
      _loading = false;
      notifyListeners(); // 🔥 ONLY ONE notify
    }
  }

  void selectStudent(Student student) {
    _isShowData.clear();
    _selectedStudent = student;
    print('student ${student}');
    notifyListeners();
  }

  /// ================= FETCH =================
  bool get isCustomerRegistered {
    return _customer != null && _customer?.mbId != null;
  }

  // branch selection
  String? selectedBranch;

  void setSelectedBranch(String branch) {
    selectedBranch = branch;
    notifyListeners();
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

  ///
  Future<void> fetchCustomerData() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final auth = FirebaseAuth.instance.currentUser;

      final uri = Uri.parse(
        // TODO current user email
        "${ApiConfigService.endpoints.getProfile}${auth?.email}",
      );

      final response = await http.get(
        uri,
        headers: {'api-key': "60e35fdc-401d-494d-9d78-39b15e345547"},
      );
      print('fetch customer data ===>>> ${response.statusCode}');
      // print('fetch customer data Body ===>>> ${response.statusCode}');
      if (response.statusCode != 200) {
        /// 🚨 BLOCK APP IF NOT REGISTERED
        // if (auth != null && !isCustomerRegistered) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     showNotCustomerDialog(navigatorKey.currentContext!);
        //   });
        // }
        throw Exception('HTTP ${response.statusCode}');
      }

      final jsonBody = json.decode(response.body);
      final parsed = CustomerResponse.fromJson(jsonBody);

      _customer = parsed.customer;
      _students = parsed.students;

      /// ✅ Default first student
      if (_students.isNotEmpty) {
        _selectedStudent ??= _students.first;
      }
      print('isCustomerRegistered $isCustomerRegistered');
      print('auth $auth');
    } catch (e) {
      print('errro fetch cusomter $e');
      _error = 'Failed to fetch: $e';
      _customer = null;
      _students = [];
      _selectedStudent = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // upsert cusotmer
  Future<void> upsertCustomer() async {
    // 1. Get Device and App Information dynamically
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final user = FirebaseAuth.instance.currentUser;
    String deviceId = '';
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // Unique ID for Android
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? ''; // Unique ID for iOS

      print('deviceId = iosInfo.identifierForVendor ${deviceId}');
    }
    final token = await getDeviceToken();
    // 2. Prepare the request body (Matches your screenshot)
    final Map<String, dynamic> body = {
      "firstname": customer?.firstName,
      "lastname": customer?.lastName,
      "clientId": customer?.mbId,
      "email": user?.email ?? "",
      //customer?.territoryid,
      "countrycode": customer?.mobileCountryCode,
      "areacode": customer?.mobileAreaCode,
      "phone": customer?.mobilePhone,
      "gender": customer?.gender,
      "FcmToken": token, // You can add your Firebase Messaging token here
      "platform": Platform.isIOS ? "ios" : "android",
      "appversion": packageInfo.version,
      "deviceId": deviceId,
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfigService.endpoints.upsertCustomer),
        headers: {
          "Content-Type": "application/json",
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },

        body: jsonEncode(body),
      );
      print('upsertCustomer response==== ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isShowData.add('Add list of data');
        print("Customer upserted successfully: ${response.body}");
      } else {
        print("Failed to upsert customer: ${response.statusCode}");
      }
    } catch (e) {
      print("Error calling upsert API: $e");
    }
  }

  String? toApiDob(String? uiDate) {
    if (uiDate == null || uiDate.isEmpty) return null;

    try {
      final parsed = DateFormat('d MMM yyyy').parse(uiDate);
      return parsed.toUtc().toIso8601String();
    } catch (e) {
      debugPrint('DOB parse error: $uiDate');
      return null;
    }
  }

  /// upsert student
  Future<bool> upsertStudentProfile(
    BuildContext context, {
    required String firstname,
    required String lastname,
    required String email,
    required String phone,
    required String countryCode,
    required String areaCode,
    String? clientId,
    String? gender,
    String? relationship,
    required String level, // Beginner | Intermediate | Experienced
    required bool existing,
    String? dateofbirth,
    String? type,
    String? reason,
    String? note,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    print('dateofbirth ${dateofbirth}');
    final dob = toApiDob(dateofbirth);
    print('dob ${dob}');
    try {
      final uri = Uri.parse(ApiConfigService.endpoints.upsertProfile);
      final body = {
        "firstname": firstname,
        "lastname": lastname,
        "email": customer?.email,
        "parentid": customer?.mbId,
        "relatedcontact": students.map((e) => e.mbId).join(","), // 👈 club ids
        "clientid": existing == false ? "" : clientId,
        "countrycode": "${selectedCountry?.name}",
        "areacode": "${selectedArea?.value}",
        "phone": phone,
        "dateofbirth": "$dob",
        "gender": gender ?? "",
        "relationship": relationship ?? "",
        "level": level,
        "existing": existing,
        "type": type ?? "",
        // "Update", "",// New, Update, Delete
        "reason": reason ?? "",
        // "Privacy Concerns",
        "note": note ?? "",
        //   "I rather use whatsapp, I dont want my information saved on this app",
      };
      print("body $body");
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },

        body: jsonEncode(body),
      );
      print("upsertporfile ${response.statusCode}");
      if (response.statusCode == 200) {
        //   final newStudent = Student(
        //     mbId: '', // API returned id
        //     firstName: firstname,
        //     lastName: lastname,
        //     fullName: "$firstname $lastname",
        //     email: email,
        //     isregistred: "No",
        //     dateOfBirth: '',
        //     emirateId: '',
        //     city: '',
        //     county: '',
        //     areaId: '',
        //     overriddenCreatedOn: '',
        //     statuscode: '',
        //     gender: '',
        //     guardianId: '',
        //   );
        return true;
      }

      /// 🔥 If new student → auto select last
      if (!existing && _students.isNotEmpty) {
        _selectedStudent = _students.last;
      }
      return false;
    } catch (e) {
      print('error sss $e');

      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  //upsert profile for deleting user
  Future<void> upsertStudentProfileDelete(
    BuildContext context, {
    required String firstname,
    required String lastname,
    required String email,
    required String phone,
    required String countryCode,
    required String areaCode,
    String? clientId,
    String? dateOfBirth,
    String? gender,
    String? relationship,
    required String level, // Beginner | Intermediate | Experienced
    required bool existing,
    String? type,
    String? reason,
    String? note,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final _googleSignin = GoogleSignIn();

    try {
      final uri = Uri.parse(ApiConfigService.endpoints.upsertProfile);
      print('selectedCountry ${selectedCountry}');
      final body = {
        "firstname": firstname,
        "lastname": lastname,
        "email": customer?.email,
        "parentid": customer?.mbId,
        "relatedcontact": students.map((e) => e.mbId).join(","), // 👈 club ids
        "clientid": existing == false ? "" : clientId,
        "countrycode": "$selectedCountry",
        "areacode": "${selectedArea}",
        "phone": phone,
        "dateofbirth": "2021-11-10T00:00:00Z",
        "gender": gender ?? "",
        "relationship": relationship ?? "",
        "level": level,
        "existing": existing,
        "type": type,
        //"Update", // New, Update, Delete
        "reason": reason,
        // "Privacy Concerns",
        "note": note,
        //   "I rather use whatsapp, I dont want my information saved on this app",
      };
      print("body $body");
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },
        body: jsonEncode(body),
      );
      print("response ${response.statusCode}");
      if (response.statusCode != 200) {
        throw Exception(response.body);
      }
      // final provider= Provider.of(Context)
      /// 🔥 Refresh customer + students
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .delete();
      await auth.currentUser!.delete();
      await _googleSignin.signOut(); // Sign out from Google
      // await fetchCustomerData();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (Route<dynamic> route) => false,
      );

      /// 🔥 If new student → auto select last
      if (!existing && _students.isNotEmpty) {
        _selectedStudent = _students.last;
      }
    } catch (e) {
      print('erppopoer $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// ================= ACTIONS =================

  void addStudent(Student student) {
    _students.add(student);
    if (_selectedStudent == null) {
      _selectedStudent = student;
    }
    notifyListeners();
  }

  void clear() {
    _customer = null;
    _students = [];
    _selectedStudent = null;
    _error = null;
    notifyListeners();
  }

  // get country code
  List<CountryCodeModel> countryCodes = [];
  List<AreaCodeModel> areaCodes = [];

  CountryCodeModel? selectedCountry;
  AreaCodeModel? selectedArea;
  List<CountryCodeModel> allCountryCodes = []; // Your original list
  String _searchQuery = "";

  // This is the list the UI will display
  List<CountryCodeModel> get filteredCountryCodes {
    if (_searchQuery.isEmpty) {
      return allCountryCodes;
    }
    return allCountryCodes
        .where(
          (c) => c.name.toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchPhoneMeta() async {
    final uri = Uri.parse(ApiConfigService.endpoints.getCountryCodes);

    try {
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'api-key': "60e35fdc-401d-494d-9d78-39b15e345547",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        countryCodes = (decoded['countrycodes'] as List)
            .map((e) => CountryCodeModel.fromJson(e))
            .toList();

        areaCodes = (decoded['areacodes'] as List)
            .map((e) => AreaCodeModel.fromJson(e))
            .toList();

        notifyListeners();
      } else {
        throw Exception('Failed to load phone meta');
      }
    } catch (e) {
      debugPrint('API error: $e');
    }
  }
}
