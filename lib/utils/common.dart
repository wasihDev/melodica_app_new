// import 'dart:developer';
// import 'dart:ui';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:dio/dio.dart';

// class MelodicaTheme {
//   static bool dark = false;
//   //static Color primary = Color(0xFFFBE037); // light
//   static Color primary = const Color(0xFFFFCB05); // dark
//   static Color secondary = dark ? Colors.white70 : const Color(0xFF343A50);
// }

// class Dynamics {
//   static String profileEmail = FirebaseAuth.instance.currentUser!.email!;
//   static String profileId = '';
//   static String profileFirstName = '';
//   static String profileLastName = '';
//   static String profilePhone = '';
//   static Map<String, dynamic>? profileCountryCode;
//   static Map<String, dynamic>? profileAreaCode;
//   static String profilePaymentToken = '';
//   static String? profileFcmToken;
//   static bool? profileRegistered;

//   static List<dynamic> flowlinks = [];

//   static List<dynamic> services = [];
//   static List<dynamic> relationships = [];
//   //static List<dynamic> branches = [];
//   static List<dynamic> schedule = [];
//   static List<dynamic> packages = [];
//   //static Map<String, String> flowlinks = {};
//   static List<dynamic> basket = [];
//   static List<dynamic> locations = [];
//   static List<dynamic> connectionRoles = [];
//   static List<dynamic> genders = [];
//   static List<dynamic> countryCodes = [];
//   static List<dynamic> areaCodes = [];

//   static String upsertProfileLink = '';
//   static String getCategories = '';
//   static String getProfileLink = '';
//   static String upsertBasketLink = '';
//   static String getBasketLink = '';
//   static String deleteBasketLink = '';
//   static String installPackageLink = '';
//   static String getPackagesLink = '';
//   static String getScheduleLink = '';
//   static String getLocationsLink = '';
//   static String getAvailabilityLink = '';
//   static String getConnectionRolesLink = '';
//   static String getGendersLink = '';
//   static String upsertFamilyInformationLink = '';
//   static String getCountryCodesLink = '';
//   //static String getServicesLink = '';

//   static bool syncd = false;

//   static Future<bool> initialize() async {
//     profileEmail = FirebaseAuth.instance.currentUser!.email!;
//     var fcmtoken = await FirebaseMessaging.instance.getToken();

//     var resp = await MelodicaHttp().get(
//       'https://prod-199.westeurope.logic.azure.com:443/workflows/47e602f17da746cc9ed04392d4f3db70/triggers/manual/paths/invoke?api-version=2016-06-01&sp=/triggers/manual/run&sv=1.0&sig=60drjf5Fiu7VHXH3KFPbXjV9y9CTuyAgiHXkzDlkqgU',
//     );

//     if (resp.data["success"] == true) {
//       //classes = resp.data["classes"];
//       flowlinks = resp.data["flowlinks"];

//       upsertProfileLink = resp.data["upsert_profile"];
//       getProfileLink = resp.data["get_profile"];
//       upsertBasketLink = resp.data["upsert_basket"];
//       getBasketLink = resp.data["get_basket"];
//       deleteBasketLink = resp.data["delete_basket"];
//       installPackageLink = resp.data["install_package"];
//       getPackagesLink = resp.data["get_packages"];
//       getScheduleLink = resp.data["get_schedule"];
//       getLocationsLink = resp.data["get_locations"];
//       getAvailabilityLink = resp.data["get_availability"];
//       getConnectionRolesLink = resp.data["get_connection_roles"];
//       getGendersLink = resp.data["get_genders"];
//       upsertFamilyInformationLink = resp.data["upsert_family_information"];
//       getCountryCodesLink = resp.data["get_country_codes"];
//       //getServicesLink = resp.data["get_services"];

//       syncd = true;
//       getLocations();
//       getConnectionRoles();
//       getGenders();
//       getCountryCodes();
//       getServices();
//       await getProfile();

//       if (profileFcmToken != fcmtoken) {
//         upsertProfile(fcmToken: fcmtoken);
//       }

//       return Future(() => syncd);
//     }
//     return Future.error(resp.data["message"]);
//   }

//   static Future<Map<String, dynamic>> upsertProfile({
//     String? firstName,
//     String? lastName,
//     String? mobilePhone,
//     Map<String, dynamic>? countryCode,
//     Map<String, dynamic>? areaCode,
//     String? paymentToken,
//     String? fcmToken,
//     String? customerId,
//   }) async {
//     try {
//       var resp = await MelodicaHttp().post(upsertProfileLink, {
//         "email": profileEmail,
//         "firstname": firstName ?? profileFirstName,
//         "lastname": lastName ?? profileLastName,
//         "mobilephone": mobilePhone ?? profilePhone,
//         "countryCode": countryCode ?? profileCountryCode,
//         "areaCode": areaCode ?? profileAreaCode,
//         "paymenttoken": paymentToken ?? profilePaymentToken,
//         "storedfcmtoken": fcmToken ?? profileFcmToken,
//         "contactid": customerId ?? profileId,
//       });

//       if (resp.data["response"] == true && !syncd) {
//         profileFirstName = firstName ?? profileFirstName;
//         profileLastName = lastName ?? profileLastName;
//         profilePhone = mobilePhone ?? profilePhone;
//         profileCountryCode = countryCode ?? profileCountryCode;
//         profileAreaCode = areaCode ?? profileAreaCode;
//         profilePaymentToken = paymentToken ?? profilePaymentToken;
//         profileFcmToken = fcmToken ?? profileFcmToken;
//         profileId = customerId ?? profileId;
//       }

//       return resp.data;
//     } catch (e) {
//       return {"response": false, "message": e.toString()};
//     }
//   }

//   static Future<String> upsertRelationship({
//     int? fromConn,
//     int? toConn,
//     String? firstName,
//     String? lastName,
//     int? gender,
//     DateTime? dob,
//     int? age,
//     bool? pc,
//   }) async {
//     var resp = await MelodicaHttp().post(upsertFamilyInformationLink, {
//       "fromConn": fromConn,
//       "toConn": toConn,
//       "firstName": firstName,
//       "lastName": lastName,
//       "gender": gender,
//       "dob": dob?.toIso8601String(),
//       "age": age,
//       "pc": pc,
//       "customer": profileId,
//     });

//     // if (resp.data["response"] == true && !syncd) {
//     //   firstname = firstName ?? firstname;
//     //   lastname = lastName ?? lastname;
//     //   phone = mobilePhone ?? phone;
//     //   paymenttoken = token ?? paymenttoken;
//     //   storedfcmtoken = fcmtoken ?? storedfcmtoken;
//     //   customerid = customerId ?? customerid;
//     // }

//     return resp.data.toString();
//   }

//   static Future<bool> getProfile() async {
//     var resp = await MelodicaHttp().get("$getProfileLink&email=$profileEmail");
//     if (resp.data != null) {
//       var profile = resp.data;
//       profileFirstName = profile["firstname"] ?? "";
//       profileLastName = profile["lastname"] ?? "";
//       profilePhone = profile["mc_mobilenumber"] ?? "";
//       profilePaymentToken = profile["mc_paymenttoken"] ?? "";
//       profileFcmToken = profile["mc_storedfcmtoken"] ?? "";
//       profileId = profile["contactid"] ?? "";
//       profileRegistered = profile["mc_isregistered"] ?? "";
//       relationships =
//           profile["mc_contact_mc_familyinformation_ConnectedFrom"] ?? [];
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> getLocations() async {
//     var resp = await MelodicaHttp().get(getLocationsLink);
//     if (resp.data != null) {
//       locations = resp.data;
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> getBasket() async {
//     var resp = await MelodicaHttp().get(
//       "$getBasketLink&customer=$profileEmail",
//     );
//     if (resp.data.length > 0) {
//       //todo: remove this when dynamics is connected
//       List<dynamic> returnedbasket = resp.data["basket"];
//       for (var a = 0; a < returnedbasket.length; a++) {
//         var b = returnedbasket[a];
//         if (basket.isEmpty) {
//           basket.add(b);
//         }
//         var match = -1;
//         for (var i = 0; i < basket.length; i++) {
//           if (basket[i]["id"] == b["id"]) {
//             match = i;
//           }
//         }
//         if (match >= 0) {
//           basket[match] = b;
//         } else {
//           basket.add(b);
//         }
//       }

//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> upsertBasket(Map<String, dynamic> item) async {
//     var resp = await MelodicaHttp().post(upsertBasketLink, item);
//     if (resp.data.length > 0) {
//       //todo: remove this when dynamics is connected
//       List<dynamic> returnedbasket = resp.data["basket"];
//       for (var a = 0; a < returnedbasket.length; a++) {
//         var b = returnedbasket[a];
//         if (basket.isEmpty) {
//           basket.add(b);
//         }
//         var match = -1;
//         for (var i = 0; i < basket.length; i++) {
//           if (basket[i]["id"] == b["id"]) {
//             match = i;
//           }
//         }
//         if (match >= 0) {
//           basket[match] = b;
//         } else {
//           basket.add(b);
//         }
//       }
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> deleteBasketItem(String id) async {
//     var resp = await MelodicaHttp().delete("$deleteBasketLink&id=$id");
//     return Future(() => resp.data["response"]);
//   }

//   static Future<bool> installPackage(List<Map<String, dynamic>> items) async {
//     var resp = await MelodicaHttp().post(installPackageLink, items);
//     if (resp.data["response"]) {
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> getPackages() async {
//     var resp = await MelodicaHttp().get(
//       "$getPackagesLink&customer=$profileEmail",
//     );
//     if (resp.data.length > 0) {
//       packages = resp.data["packages"];
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> getOrders() async {
//     // var resp = await MelodicaHttp().get(
//     //   "$get_orders&customer=$email",
//     // );
//     // if (resp.data.length > 0) {
//     //   packages = resp.data["orders"];
//     //   return Future(() => true);
//     // }

//     return Future(() => false);
//   }

//   static Future<bool> getSchedule() async {
//     var resp = await MelodicaHttp().get("$getScheduleLink&customer=$profileId");
//     if (resp.data.length > 0) {
//       schedule = resp.data;
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> getConnectionRoles() async {
//     var resp = await MelodicaHttp().get(getConnectionRolesLink);
//     if (resp.data.length > 0) {
//       connectionRoles = resp.data;
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> getGenders() async {
//     var resp = await MelodicaHttp().get(getGendersLink);
//     if (resp.data.length > 0) {
//       genders = resp.data;
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> getCountryCodes() async {
//     var resp = await MelodicaHttp().get(getCountryCodesLink);
//     if (resp.data.length > 0) {
//       countryCodes = resp.data["countrycodes"];
//       areaCodes = resp.data["areacodes"];
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<bool> getServices() async {
//     var resp = await MelodicaHttp().get(
//       flowlinks.firstWhere((link) => link["key"] == "get_services")?["value"],
//     );
//     if (resp.data["success"]) {
//       services = resp.data["services"];
//       return Future(() => true);
//     }

//     return Future(() => false);
//   }

//   static Future<List<dynamic>> getAvailability(
//     String resourceid,
//     DateTime from,
//     DateTime to,
//     int duration,
//   ) async {
//     var resp = await MelodicaHttp().get(
//       "$getAvailabilityLink&from=${from.toIso8601String()}&to=${to.toIso8601String()}&duration=$duration&resource=$resourceid",
//     );
//     if (resp.data.length > 0 && resp.data["TimeSlots"].length > 0) {
//       return Future(() => resp.data["TimeSlots"]);
//     }

//     return Future(() => []);
//   }
// }

// class Common {
//   // static PreferredSizeWidget GetAppBar(BuildContext context, String title, void Function()? actionCallBack) {
//   //   return AppBar(
//   //     elevation: 0,
//   //     backgroundColor: MelodicaTheme.primary,
//   //     title: Row(
//   //       crossAxisAlignment: CrossAxisAlignment.end,
//   //       mainAxisAlignment: MainAxisAlignment.start,
//   //       children: [
//   //         Image.asset(
//   //           'lib/images/melodica_logo.png',
//   //           alignment: Alignment.topLeft,
//   //           height: 25,
//   //           fit: BoxFit.fitHeight,
//   //           color: const Color(0xFF343A50),
//   //         ),
//   //         Container(
//   //           padding: const EdgeInsets.symmetric(horizontal: 10),
//   //           width: 200,
//   //           alignment: Alignment.bottomCenter,
//   //           child: Text(
//   //             title,
//   //             style: const TextStyle(
//   //               color: Color(0xFF343A50),
//   //               fontWeight: FontWeight.bold,
//   //               fontSize: 14,
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),

//   //     // leading: Image.asset(
//   //     //   'lib/images/melodica_logo.png',
//   //     //   alignment: Alignment.topLeft,
//   //     //   height: 2000,
//   //     // ),
//   //     actions: [
//   //       GestureDetector(
//   //         onTap: //actionCallBack,
//   //         () {
//   //           Navigator.push(context,
//   //               MaterialPageRoute(builder: (context) => const NotificationView()));
//   //         },
//   //         child: const Padding(
//   //           padding: EdgeInsets.only(right: 25.0),
//   //           child: Icon(Icons.notifications_rounded),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // SizedBox BuildSelectableGrid(
//   //     List<dynamic> list, Function(int index) onGridItemTap) {
//   //   return SizedBox(
//   //     height: 400,
//   //     child: GridView.builder(
//   //       gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//   //         maxCrossAxisExtent: 100,
//   //         childAspectRatio: 0.8,
//   //         crossAxisSpacing: 5,
//   //         mainAxisSpacing: 5,
//   //       ),
//   //       itemCount: list.length,
//   //       itemBuilder: (BuildContext ctx, index) {
//   //         return GestureDetector(
//   //           onTap: () {
//   //             onGridItemTap(index);
//   //           },
//   //           child: Padding(
//   //             padding: const EdgeInsets.all(10),
//   //             child: Container(
//   //               alignment: Alignment.center,
//   //               decoration: BoxDecoration(
//   //                 color: selectedValue == list[index]["title"]
//   //                     ? MelodicaTheme.primary
//   //                     : Colors.white70,
//   //                 border: Border.all(
//   //                   color: Colors.white,
//   //                 ),
//   //                 boxShadow: [
//   //                   BoxShadow(
//   //                     blurRadius: 10,
//   //                     blurStyle: BlurStyle.outer,
//   //                     color: Colors.grey.shade300,
//   //                   ),
//   //                 ],
//   //                 borderRadius: BorderRadius.circular(20),
//   //               ),
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.center,
//   //                 mainAxisAlignment: MainAxisAlignment.center,
//   //                 children: [
//   //                   Image.network(list[index]["image"], height: 40),
//   //                   // Icon(
//   //                   //   widget.icon,
//   //                   //   size: 40,
//   //                   //   color: Colors.grey.shade600,
//   //                   // ),
//   //                   Text(
//   //                     list[index]["name"],
//   //                     textAlign: TextAlign.center,
//   //                     style: TextStyle(
//   //                       fontSize: 15,
//   //                       fontWeight: FontWeight.bold,
//   //                       color: Colors.grey.shade600,
//   //                     ),
//   //                   )
//   //                 ],
//   //               ),
//   //             ),
//   //           ),
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }
//   // static List<dynamic> days = jsonDecode('''
//   //     [
//   //       {
//   //         "name": "Monday"
//   //       },
//   //       {
//   //         "name": "Tuesday"
//   //       },
//   //       {
//   //         "name": "Wednesday"
//   //       },
//   //       {
//   //         "name": "Thursday"
//   //       },
//   //       {
//   //         "name": "Friday"
//   //       },
//   //       {
//   //         "name": "Saturday"
//   //       },
//   //       {
//   //         "name": "Sunday"
//   //       }
//   //     ]''');

//   // static List<dynamic> timeOfDay = jsonDecode('''
//   //     [
//   //       {
//   //         "name": "Mornings"
//   //       },
//   //       {
//   //         "name": "Afternoons"
//   //       },
//   //       {
//   //         "name": "Evenings"
//   //       }
//   //     ]''');

//   static List<Map<String, dynamic>> twoOptions = [
//     {"name": "Yes", "value": true},
//     {"name": "No", "value": false},
//   ];
//   static void goToPage(BuildContext context, Widget page) {
//     Navigator.push(context, MaterialPageRoute(builder: (context) => page));
//   }

//   static void completePopup(BuildContext context) {
//     showCustomDialog(
//       context,
//       Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.lightGreenAccent.shade400,
//                   width: 3,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.lightGreenAccent.shade400,
//                     blurRadius: 1,
//                     blurStyle: BlurStyle.outer,
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.done,
//                 color: Colors.lightGreenAccent.shade400,
//                 size: 40,
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               "DONE",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//       height: 150,
//       width: 200,
//     );
//   }

//   static void optionList(
//     BuildContext context,
//     List<Map<String, dynamic>> list,
//   ) {
//     showCustomDialog(
//       context,
//       Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: List.generate(list.length, (index) {
//             return GestureDetector(
//               onTap: () {
//                 list[index]["action"]();
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.grey.shade900.withOpacity(0.85),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Text(
//                           list[index]["name"],
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w900,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 40,
//                       child: VerticalDivider(
//                         color: Colors.grey.shade700,
//                         thickness: 2,
//                       ),
//                     ),
//                     const Icon(
//                       Icons.chevron_right_outlined,
//                       color: Colors.white,
//                       size: 40,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//       backgroundColor: Colors.transparent,
//       height: (80 * list.length).toDouble(),
//       width: 300,
//     );
//   }

//   static void showCustomDialog(
//     BuildContext context,
//     Widget child, {
//     double height = 300,
//     double width = 300,
//     Color? backgroundColor,
//   }) {
//     showCupertinoModalPopup<void>(
//       context: context,
//       filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//       barrierColor: Colors.white.withOpacity(0.2),
//       builder: (context) {
//         backgroundColor ??= Colors.grey.shade900.withOpacity(0.85);
//         return Center(
//           child: Container(
//             decoration: BoxDecoration(
//               color: backgroundColor,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             // margin: const EdgeInsets.symmetric(horizontal: 25),
//             height: height,
//             width: width,
//             child: Scaffold(
//               backgroundColor: Colors.transparent,
//               body: Container(child: child),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   static void confirmMessage(
//     BuildContext context,
//     String message,
//     Function() confirm,
//     Function() cancel,
//   ) {
//     showCustomDialog(
//       context,
//       Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 20),
//               child: Icon(
//                 Icons.error_outline,
//                 color: Colors.red.shade700,
//                 size: 100,
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//                 child: Text(
//                   message,
//                   style: const TextStyle(color: Colors.white, fontSize: 18),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//             Divider(color: Colors.grey.shade600, thickness: 1),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context);
//                     cancel();
//                   },
//                   child: const Text(
//                     "No",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Container(
//                   height: 70,
//                   padding: EdgeInsets.zero,
//                   margin: EdgeInsets.zero,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade600, width: 1),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context);
//                     confirm();
//                   },
//                   child: Text(
//                     "Yes",
//                     style: TextStyle(
//                       color: Colors.red.shade600,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static void errorMessage(
//     BuildContext context,
//     String message, {
//     Function()? confirm,
//     Function()? cancel,
//   }) {
//     var errorIcon = Padding(
//       padding: const EdgeInsets.only(top: 20),
//       child: Image.asset("lib/icons/exclamation-mark.png"),
//       // Icon(
//       //   Icons.error_outline,
//       //   color: Colors.red.shade700,
//       //   size: 100,
//       // ),
//     );
//     var errorMessage = Expanded(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Text(
//           message,
//           style: const TextStyle(color: Colors.white, fontSize: 18),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );

//     List<Widget> actionsLis;

//     if (confirm != null && cancel != null) {
//       actionsLis = [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//             confirm();
//           },
//           child: Text(
//             "Yes",
//             style: TextStyle(
//               color: Colors.red.shade600,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         Container(
//           height: 70,
//           padding: EdgeInsets.zero,
//           margin: EdgeInsets.zero,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade600, width: 1),
//           ),
//         ),
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);

//             cancel();
//           },
//           child: const Text(
//             "No",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ];
//     } else if (confirm != null) {
//       actionsLis = [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//             confirm();
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Text(
//               "Yes",
//               style: TextStyle(
//                 color: Colors.red.shade600,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ];
//     } else if (cancel != null) {
//       actionsLis = [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);

//             cancel();
//           },
//           child: const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text(
//               "No",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ];
//     } else {
//       actionsLis = [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text(
//               "Ok",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ];
//     }

//     var actions = Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: actionsLis,
//     );

//     showCustomDialog(
//       context,
//       Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             errorIcon,
//             errorMessage,
//             Divider(color: Colors.grey.shade600, thickness: 1),
//             actions,
//           ],
//         ),
//       ),
//       height: 320,
//     );
//   }

//   // static void errorMessage(BuildContext context, String message,
//   //     {List<Widget>? actions}) {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) {
//   //       return AlertDialog(
//   //         backgroundColor: Colors.red.shade300,
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(10),
//   //         ),
//   //         title: Text(
//   //           message,
//   //           style: const TextStyle(
//   //             color: Colors.white,
//   //           ),
//   //           textAlign: TextAlign.center,
//   //         ),
//   //         actions: actions,
//   //       );
//   //     },
//   //   );
//   // }

//   static void alertMessage(
//     BuildContext context,
//     String message, {
//     Function()? confirm,
//     Function()? cancel,
//   }) {
//     var errorIcon = Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       child: Icon(
//         Icons.self_improvement_outlined,
//         color: Colors.lightGreenAccent.shade700,
//         size: 100,
//       ),
//     );
//     var errorMessage = Expanded(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Text(
//           message,
//           style: const TextStyle(color: Colors.white, fontSize: 18),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );

//     List<Widget> actionsLis;

//     if (confirm != null && cancel != null) {
//       actionsLis = [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//             confirm();
//           },
//           child: Text(
//             "Ok",
//             style: TextStyle(
//               color: Colors.lightGreenAccent.shade700,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         Container(
//           height: 70,
//           padding: EdgeInsets.zero,
//           margin: EdgeInsets.zero,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade600, width: 1),
//           ),
//         ),
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);

//             cancel();
//           },
//           child: const Text(
//             "Cancel",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ];
//     } else if (confirm != null) {
//       actionsLis = [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//             confirm();
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Text(
//               "Ok",
//               style: TextStyle(
//                 color: Colors.lightGreenAccent.shade700,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ];
//     } else if (cancel != null) {
//       actionsLis = [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);

//             cancel();
//           },
//           child: const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text(
//               "Cancel",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ];
//     } else {
//       actionsLis = [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text(
//               "Ok",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ];
//     }

//     var actions = Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: actionsLis,
//     );

//     showCustomDialog(
//       context,
//       Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           errorIcon,
//           errorMessage,
//           Divider(color: Colors.grey.shade600, thickness: 1),
//           actions,
//         ],
//       ),
//     );
//   }

//   static void loading(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );
//   }

//   static void lookup(
//     BuildContext context,
//     String message,
//     Function(Map<String, dynamic> selectedItem) onchange,
//   ) {
//     var searchCtrl = TextEditingController();
//     List<dynamic> items = [];
//     refresh({String? filter}) {
//       if (filter == null) {
//         items = Dynamics.relationships;
//       } else {
//         items = Dynamics.relationships
//             .where(
//               (r) =>
//                   r["firstname"].toString().contains(filter) ||
//                   r["lastname"].toString().contains(filter),
//             )
//             .toList();
//       }
//     }

//     refresh();

//     showCustomDialog(
//       context,
//       Container(
//         alignment: Alignment.center,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: MelodicaTextField(
//                     compact: true,
//                     controller: searchCtrl,
//                     label: message,
//                     keyboardType: TextInputType.text,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     refresh(filter: searchCtrl.text);
//                   },
//                   child: Container(
//                     alignment: Alignment.bottomRight,
//                     padding: const EdgeInsets.only(top: 15, right: 5),
//                     child: Icon(
//                       Icons.search,
//                       color: Colors.grey.shade200,
//                       size: 40,
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     //todo: go to add family member
//                   },
//                   child: Container(
//                     alignment: Alignment.bottomRight,
//                     padding: const EdgeInsets.only(top: 15, right: 5),
//                     child: Icon(
//                       Icons.person_add,
//                       color: Colors.grey.shade200,
//                       size: 40,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: Column(
//                 children: List.generate(items.length, (index) {
//                   var item = Dynamics.relationships[index];

//                   return Text(
//                     "${item["_mc_connectedto_value@OData.Community.Display.V1.FormattedValue"]}",
//                     style: const TextStyle(color: Colors.white, fontSize: 18),
//                     textAlign: TextAlign.center,
//                   );
//                 }),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MelodicaHttp {
//   Dio dio = Dio();
//   Future<Response<dynamic>> get(String url) async {
//     return await dio.get(url);
//   }

//   Future<Response<dynamic>> post(
//     String url,
//     Object? data, {
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//     CancelToken? cancelToken,
//   }) async {
//     return await dio.post(
//       url,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//       cancelToken: cancelToken,
//     );
//   }

//   Future<Response<dynamic>> delete(String url) async {
//     return await dio.delete(url);
//   }
// }

// class MelodicaCommonAppbar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final String? imageLocation;
//   final bool showLeading;
//   const MelodicaCommonAppbar({
//     super.key,
//     this.imageLocation,
//     this.showLeading = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       systemOverlayStyle: const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//         statusBarBrightness: Brightness.dark,
//       ),
//       flexibleSpace: Stack(
//         children: [
//           ClipPath(
//             clipper: CustomShape(50),
//             child: Container(
//               height: 200,
//               width: MediaQuery.of(context).size.width,
//               color: MelodicaTheme.primary,
//             ),
//           ),
//           if (imageLocation != null) ...[
//             ClipPath(
//               clipper: CustomShape(80),
//               child: Image.asset(
//                 imageLocation!,
//                 alignment: Alignment.centerLeft,
//                 //height: MediaQuery.of(context).size.width > 450 ? 400 : 200,
//                 width: MediaQuery.of(context).size.width,
//                 height: 400,
//                 fit: BoxFit.cover,
//                 // fit: MediaQuery.of(context).size.width > 450
//                 //     ? BoxFit.fitWidth
//                 //     : BoxFit.fitHeight,
//               ),
//             ),
//           ] else ...[
//             Container(
//               alignment: Alignment.center,
//               child: Image.asset(
//                 'lib/images/melodica_logo.png',
//                 alignment: Alignment.topLeft,
//                 height: 70,
//                 fit: BoxFit.fitHeight,
//                 color: Colors.grey.shade900,
//               ),
//             ),
//           ],
//         ],
//       ),
//       leading: !showLeading
//           ? null
//           : GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Container(
//                 margin: const EdgeInsets.symmetric(
//                   horizontal: 35,
//                   vertical: 15,
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(50),
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       offset: const Offset(5, 5),
//                       blurRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: const Icon(Icons.arrow_back_ios_new, size: 18),
//               ),
//             ),
//       elevation: 0,
//       leadingWidth: 100,
//       automaticallyImplyLeading: false,
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(150);
// }

// enum MelodicaComponentSize { small, medium, large }

// ///A grid builder that lets the user select a single item and outputs the selected item in the callback.
// ///
// ///The [data], [onChangeSelectedItem] and [size] arguments must not be null.
// ///
// ///The [data] argument is a List<dynamic> that accepts a list of any object that contains a 'name' key and potentially an 'image' key.
// // ignore: must_be_immutable
// class MelodicaSelectableGrid extends StatefulWidget {
//   final List<dynamic> data;
//   final MelodicaComponentSize size;
//   final Function(String)? onChangeSelectedItem;
//   //final Function(Map<int, dynamic>)? onChangeSelectedItem;
//   final Function(List<dynamic>)? onChangeMultiSelectedItem;
//   final String? label;
//   final bool? multipleSelect;
//   String? defaultItem;
//   //Map<int, dynamic>? defaultItem;
//   final List<dynamic>? defaultItems;

//   MelodicaSelectableGrid({
//     super.key,
//     required this.data,
//     required this.size,
//     this.onChangeSelectedItem,
//     this.onChangeMultiSelectedItem,
//     this.label,
//     this.multipleSelect = false,
//     this.defaultItem,
//     this.defaultItems,
//   });

//   @override
//   State<MelodicaSelectableGrid> createState() => _MelodicaSelectableGridState();
// }

// // class MelodicaSelectableGridItem {
// //   MelodicaSelectableGridItem(int index, String value) {
// //     Index = index;
// //     Value = value;
// //   }

// //   int? Index;
// //   String? Value;
// // }

// class _MelodicaSelectableGridState extends State<MelodicaSelectableGrid> {
//   var _hasImage = false;
//   List<dynamic> _selectedItems = [];
//   //Map<int, dynamic>? _selectedItem;
//   String? _selectedItem;

//   @override
//   Widget build(BuildContext context) {
//     for (var item in widget.data) {
//       if (item["image"] != null) {
//         _hasImage = true;
//       }
//     }

//     _selectedItems = widget.defaultItems ?? _selectedItems;

//     _selectedItem = widget.defaultItem ?? _selectedItem;

//     bool isSelected(int index) {
//       if (_selectedItem != null) {
//         //var selectedItemText = _selectedItem!.values.first["name"];
//         var itterationItemText = widget.data[index]["name"];

//         //if (selectedItemText == itterationItemText) {
//         if (_selectedItem == itterationItemText) {
//           return true;
//         }
//       }

//       if (_selectedItems.isNotEmpty) {
//         if (_selectedItems
//             .where(
//               (item) => item.values
//                   .where((x) => x["name"] == widget.data[index]["name"])
//                   .isNotEmpty,
//             )
//             .isNotEmpty) {
//           return true;
//         }
//       }

//       return false;
//     }

//     var screenwidth = MediaQuery.of(context).size.width;

//     var rowcount =
//         (widget.data.length /
//                 (MediaQuery.of(context).size.width > 450
//                     ? 6
//                     : widget.data.length < 3
//                     ? 2
//                     : 3))
//             .ceilToDouble();

//     var singleitemsize = (widget.size == MelodicaComponentSize.small
//         ? (_hasImage
//               ? (screenwidth > 450
//                     ? screenwidth / (widget.data.length < 3 ? 14 : 6.5)
//                     : screenwidth / (widget.data.length < 3 ? 6.5 : 6.5))
//               : (screenwidth > 450
//                     ? screenwidth / (widget.data.length < 3 ? 8 : 13)
//                     : screenwidth / (widget.data.length < 3 ? 10 : 10)))
//         : widget.size == MelodicaComponentSize.medium
//         ? (_hasImage
//               ? (screenwidth > 450
//                     ? screenwidth / (widget.data.length < 3 ? 9 : 5)
//                     : screenwidth / (widget.data.length < 3 ? 5 : 5))
//               : (screenwidth > 450
//                     ? screenwidth / (widget.data.length < 3 ? 10 : 10)
//                     : screenwidth / (widget.data.length < 3 ? 6.5 : 6.5)))
//         : (_hasImage
//               ? (screenwidth > 450
//                     ? screenwidth / (widget.data.length < 3 ? 6 : 3.5)
//                     : screenwidth / (widget.data.length < 3 ? 3 : 3))
//               : (screenwidth > 450
//                     ? screenwidth / (widget.data.length < 3 ? 7 : 7)
//                     : screenwidth / (widget.data.length < 3 ? 4.5 : 4.5))));

//     double singleitemratio = widget.size == MelodicaComponentSize.small
//         ? (_hasImage
//               ? (widget.data.length < 3
//                     ? (screenwidth > 450 ? 7 : 3)
//                     : (screenwidth > 450 ? 2 : 2))
//               : (widget.data.length < 3
//                     ? (screenwidth > 450 ? 4.5 : 4.5)
//                     : (screenwidth > 450 ? 3 : 3)))
//         : widget.size == MelodicaComponentSize.medium
//         ? (_hasImage
//               ? (widget.data.length < 3
//                     ? (screenwidth > 450 ? 4 : 2.2)
//                     : (screenwidth > 450 ? 1.5 : 1.5))
//               : (widget.data.length < 3
//                     ? (screenwidth > 450 ? 5 : 3)
//                     : (screenwidth > 450 ? 2 : 2)))
//         : (_hasImage
//               ? (widget.data.length < 3
//                     ? (screenwidth > 450 ? 3 : 1.5)
//                     : (screenwidth > 450 ? 1 : 0.9))
//               : (widget.data.length < 3
//                     ? (screenwidth > 450 ? 4 : 2.2)
//                     : (screenwidth > 450 ? 1.4 : 1.4)));

//     // var isSelected = Function(index) {
//     //   return _selectedItem != null &&
//     //           (_selectedItem!.containsKey(index) ||
//     //               _selectedItems
//     //                   .where((item) => item.containsKey(index))
//     //                   .isNotEmpty)
//     //       ? true
//     //       : false;

//     //   if (_selectedItem != null) {
//     //     if (_selectedItem!.containsKey(index) ||
//     //         _selectedItems
//     //             .where((item) => item.containsKey(index))
//     //             .isNotEmpty) {
//     //       return true;
//     //     }
//     //   }

//     //   return false;

//     // return _selectedItem != null &&
//     //     (_selectedItem!.containsKey(index) ||
//     //         _selectedItems
//     //             .where((item) => item.containsKey(index))
//     //             .isNotEmpty);
//     // };

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (widget.label != null) ...[
//           Text(widget.label!, style: TextStyle(color: Colors.grey.shade700)),
//         ],
//         SizedBox(
//           height: singleitemsize * rowcount,
//           child: GridView.builder(
//             gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//               maxCrossAxisExtent: widget.data.length < 3
//                   ? screenwidth / 2
//                   : screenwidth > 450
//                   ? screenwidth / 5
//                   : screenwidth / 3, //(_hasImage ? 100 : 200),

//               //mainAxisExtent: size == SelectableGridSize.small ? 50 : size == SelectableGridSize.medium ? 70 : 100,
//               childAspectRatio: singleitemratio,
//               crossAxisSpacing: MediaQuery.of(context).size.width > 450 ? 5 : 0,

//               // crossAxisSpacing: widget.size == SelectableGridSize.small
//               //     ? 0
//               //     : widget.size == SelectableGridSize.medium
//               //         ? 0
//               //         : 5,
//               mainAxisSpacing: MediaQuery.of(context).size.width > 450 ? 5 : 0,
//               // mainAxisSpacing: widget.size == SelectableGridSize.small
//               //     ? 0
//               //     : widget.size == SelectableGridSize.medium
//               //         ? 0
//               //         : 5,
//             ),
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: widget.data.length,
//             itemBuilder: (BuildContext ctx, index) {
//               return GestureDetector(
//                 onTap: () {
//                   if (widget.multipleSelect == false &&
//                       widget.onChangeSelectedItem != null) {
//                     // _selectedIndex = index;
//                     // _selectedValue = widget.data[index]["name"];
//                     //_selectedItem = {index: widget.data[index]};
//                     _selectedItem = widget.data[index]["name"];
//                     widget.defaultItem = _selectedItem;

//                     widget.onChangeSelectedItem!(_selectedItem!);
//                   }

//                   if (widget.multipleSelect == true &&
//                       widget.onChangeMultiSelectedItem != null) {
//                     var toglist = _selectedItems
//                         .where((item) => item.containsKey(index))
//                         .toList();
//                     if (toglist.isNotEmpty) {
//                       _selectedItems.remove(toglist.first);
//                     } else {
//                       _selectedItems.add({index: widget.data[index]});
//                     }

//                     widget.onChangeMultiSelectedItem!(_selectedItems);
//                   }
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(5),
//                   child: Container(
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: isSelected(index)
//                           ? MelodicaTheme.primary
//                           : Colors.white70,
//                       border: Border.all(color: Colors.white),
//                       boxShadow: [
//                         BoxShadow(
//                           blurRadius: 10,
//                           blurStyle: BlurStyle.outer,
//                           color: Colors.grey.shade300,
//                         ),
//                       ],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         if (widget.data[index]["image"] != null) ...[
//                           Image.network(
//                             widget.data[index]["image"] ?? "",
//                             height: widget.size == MelodicaComponentSize.small
//                                 ? 10
//                                 : widget.size == MelodicaComponentSize.medium
//                                 ? 25
//                                 : 40,
//                             color: isSelected(index)
//                                 ? Colors.white
//                                 : Colors.grey.shade600,
//                           ),
//                         ],
//                         Text(
//                           widget.data[index]["name"],
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: widget.size == MelodicaComponentSize.small
//                                 ? 12
//                                 : widget.size == MelodicaComponentSize.medium
//                                 ? 12
//                                 : 15,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected(index)
//                                 ? Colors.white
//                                 : Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class MelodicaPillSelector extends StatefulWidget {
//   final Function(Map<String, dynamic> selectedItem) onChange;
//   final List<Map<String, dynamic>> items;
//   final Map<String, dynamic> selectedItem;
//   const MelodicaPillSelector({
//     super.key,
//     required this.onChange,
//     required this.items,
//     required this.selectedItem,
//   });

//   @override
//   State<MelodicaPillSelector> createState() => _MelodicaPillSelectorState();
// }

// class _MelodicaPillSelectorState extends State<MelodicaPillSelector> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10),
//       child: Row(
//         children: List.generate(widget.items.length, (index) {
//           var pill = widget.items[index];
//           return GestureDetector(
//             onTap: () {
//               widget.onChange(pill);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: MelodicaTheme.primary),
//                 borderRadius: BorderRadius.circular(50),
//                 color: widget.selectedItem == pill
//                     ? MelodicaTheme.primary
//                     : Colors.white,
//               ),
//               margin: const EdgeInsets.only(right: 5),
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               child: Text(
//                 pill["name"]!,
//                 style: TextStyle(
//                   color: widget.selectedItem == pill
//                       ? Colors.white
//                       : Colors.grey.shade700,
//                   fontWeight: widget.selectedItem == pill
//                       ? FontWeight.bold
//                       : FontWeight.normal,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// // enum SelectableGridSize { small, medium, large }

// // class SelectableGrid {
// //   SelectableGrid();

// //   String selectedValue = "";

// //   Column Build(List<dynamic> list, Function(int index) onGridItemTap,
// //       SelectableGridSize size, double screenwidth, String? label) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         if (label != null) ...[
// //           Text(
// //             label,
// //             style: TextStyle(color: Colors.grey.shade700),
// //           ),
// //         ],
// //         SizedBox(
// //           height: (size == SelectableGridSize.small
// //                   ? 50
// //                   : size == SelectableGridSize.medium
// //                       ? 70
// //                       : 110) *
// //               //height: (compact ? 90 : 130) *
// //               (list.length /
// //                       (screenwidth > 450
// //                           ? 6
// //                           : list.length < 3
// //                               ? 2
// //                               : 3))
// //                   .ceilToDouble(),
// //           child: GridView.builder(
// //             gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
// //               maxCrossAxisExtent: list.length < 3 ? 200 : 100,
// //               //mainAxisExtent: size == SelectableGridSize.small ? 50 : size == SelectableGridSize.medium ? 70 : 100,
// //               childAspectRatio: size == SelectableGridSize.small
// //                   ? 3
// //                   : size == SelectableGridSize.medium
// //                       ? 1.5
// //                       : 0.9,
// //               crossAxisSpacing: size == SelectableGridSize.small
// //                   ? 0
// //                   : size == SelectableGridSize.medium
// //                       ? 0
// //                       : 5,
// //               mainAxisSpacing: size == SelectableGridSize.small
// //                   ? 0
// //                   : size == SelectableGridSize.medium
// //                       ? 0
// //                       : 5,
// //             ),
// //             itemCount: list.length,
// //             itemBuilder: (BuildContext ctx, index) {
// //               return GestureDetector(
// //                 onTap: () {
// //                   onGridItemTap(index);
// //                 },
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(5),
// //                   child: Container(
// //                     alignment: Alignment.center,
// //                     decoration: BoxDecoration(
// //                       color: selectedValue == list[index]["name"]
// //                           ? MelodicaTheme.primary
// //                           : Colors.white70,
// //                       border: Border.all(
// //                         color: Colors.white,
// //                       ),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           blurRadius: 10,
// //                           blurStyle: BlurStyle.outer,
// //                           color: Colors.grey.shade300,
// //                         ),
// //                       ],
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         if (list[index]["image"] != null) ...[
// //                           Image.network(list[index]["image"] ?? "",
// //                               height: size == SelectableGridSize.small
// //                                   ? 10
// //                                   : size == SelectableGridSize.medium
// //                                       ? 25
// //                                       : 40,
// //                               color: selectedValue == list[index]["name"]
// //                                   ? Colors.white
// //                                   : Colors.grey.shade600),
// //                         ],
// //                         // Icon(
// //                         //   widget.icon,
// //                         //   size: 40,
// //                         //   color: Colors.grey.shade600,
// //                         // ),
// //                         Text(
// //                           list[index]["name"],
// //                           textAlign: TextAlign.center,
// //                           style: TextStyle(
// //                             fontSize: size == SelectableGridSize.small
// //                                 ? 12
// //                                 : size == SelectableGridSize.medium
// //                                     ? 12
// //                                     : 15,
// //                             fontWeight: FontWeight.bold,
// //                             color: selectedValue == list[index]["name"]
// //                                 ? Colors.white
// //                                 : Colors.grey.shade600,
// //                           ),
// //                         )
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // ignore: must_be_immutable
// class MelodicaTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final bool obscureText;
//   final bool compact;
//   final String label;
//   final TextInputType keyboardType;
//   final Function(DateTime value)? onChangeDateSelection;
//   //final Function(Map<int, dynamic>)? onChangeDropDownSelection;
//   final Function(String)? onChangeDropDownSelection;
//   DateTime? confirmedDate;
//   String? confirmedDropDownItem;
//   //Map<int, dynamic>? confirmedDropDownItem;
//   final List<String>? dropDownItems;
//   final EdgeInsetsGeometry margin;
//   final bool leftround;
//   final bool rightround;

//   MelodicaTextField({
//     super.key,
//     required this.controller,
//     this.obscureText = false,
//     this.compact = true,
//     this.label = "...",
//     this.keyboardType = TextInputType.text,
//     this.onChangeDateSelection,
//     this.confirmedDate,
//     this.confirmedDropDownItem,
//     this.onChangeDropDownSelection,
//     this.dropDownItems,
//     this.leftround = true,
//     this.rightround = true,
//     this.margin = const EdgeInsets.only(top: 10),
//   });

//   @override
//   State<MelodicaTextField> createState() => _MelodicaTextFieldState();
// }

// class _MelodicaTextFieldState extends State<MelodicaTextField> {
//   DateTime? _selectedDate;

//   List<Widget> dropDowns = [];

//   @override
//   Widget build(BuildContext context) {
//     if (widget.confirmedDate != null) {
//       widget.controller.text = DateFormat(
//         "EEEE, MMM d, yyyy",
//       ).format(widget.confirmedDate!);
//     }
//     if (widget.confirmedDropDownItem != null) {
//       widget.controller.text = widget.confirmedDropDownItem!;
//       //widget.confirmedDropDownItem!["value"].toString();
//     }
//     if (widget.dropDownItems != null &&
//         widget.onChangeDropDownSelection != null) {
//       dropDowns = [];
//       for (var i = 0; i < widget.dropDownItems!.length; i++) {
//         var item = widget.dropDownItems![i];
//         dropDowns.add(
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 widget.confirmedDropDownItem = item;
//                 widget.controller.text = item;
//                 //widget.onChangeDropDownSelection!({i: item});
//                 widget.onChangeDropDownSelection!(item);
//                 Navigator.pop(context);
//               });
//             },
//             child: Row(children: [Text(item)]),
//           ),
//         );
//       }
//     }

//     return Padding(
//       padding: widget.margin,
//       child: TextField(
//         controller: widget.controller,
//         obscureText: widget.obscureText,
//         maxLines: widget.keyboardType == TextInputType.multiline ? 10 : 1,
//         keyboardType: widget.keyboardType == TextInputType.datetime
//             ? TextInputType.none
//             : widget.keyboardType,
//         style: TextStyle(color: Colors.grey.shade800),
//         onTap: () {
//           if (widget.keyboardType == TextInputType.datetime) {
//             Common.showCustomDialog(
//               context,
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//                     child: Text(
//                       "Use the slides to select a date",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey.shade100,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       color: Colors.grey.shade200,
//                     ),
//                     margin: const EdgeInsets.symmetric(horizontal: 10),
//                     height: 200,
//                     child: CupertinoDatePicker(
//                       mode: CupertinoDatePickerMode.date,
//                       initialDateTime: widget.confirmedDate ?? DateTime.now(),
//                       dateOrder: DatePickerDateOrder.dmy,
//                       onDateTimeChanged: (DateTime newDateTime) {
//                         _selectedDate = newDateTime.toLocal();
//                       },
//                       maximumYear: DateTime.now().year,
//                     ),
//                   ),
//                   const MelodicaPageDivider(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Text(
//                           "Cancel",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       Container(
//                         height: 70,
//                         padding: EdgeInsets.zero,
//                         margin: EdgeInsets.zero,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: Colors.grey.shade600,
//                             width: 1,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           widget.confirmedDate = _selectedDate;

//                           widget.controller.text = _selectedDate != null
//                               ? DateFormat(
//                                   "EEEE, MMM d, yyyy",
//                                 ).format(_selectedDate!)
//                               : "";

//                           if (widget.onChangeDateSelection != null) {
//                             widget.onChangeDateSelection!(
//                               widget.confirmedDate!,
//                             );
//                           }
//                           Navigator.pop(context);
//                         },
//                         child: Text(
//                           "Confirm",
//                           style: TextStyle(
//                             color: Colors.red.shade600,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               height: 380,
//               width: 320,
//             );
//           } else if (widget.onChangeDropDownSelection != null &&
//               widget.dropDownItems != null) {
//             Common.showCustomDialog(
//               context,
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: dropDowns,
//               ),
//             );
//           }
//         },
//         decoration: InputDecoration(
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey.shade400),
//             borderRadius: BorderRadius.only(
//               bottomLeft: widget.leftround
//                   ? const Radius.circular(20)
//                   : Radius.zero,
//               topLeft: widget.leftround
//                   ? const Radius.circular(20)
//                   : Radius.zero,
//               bottomRight: widget.rightround
//                   ? const Radius.circular(20)
//                   : Radius.zero,
//               topRight: widget.rightround
//                   ? const Radius.circular(20)
//                   : Radius.zero,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: MelodicaTheme.primary),
//             borderRadius: BorderRadius.only(
//               bottomLeft: widget.leftround
//                   ? const Radius.circular(20)
//                   : Radius.zero,
//               topLeft: widget.leftround
//                   ? const Radius.circular(20)
//                   : Radius.zero,
//               bottomRight: widget.rightround
//                   ? const Radius.circular(20)
//                   : Radius.zero,
//               topRight: widget.rightround
//                   ? const Radius.circular(20)
//                   : Radius.zero,
//             ),
//           ),
//           fillColor: Colors.white,
//           filled: true,
//           labelText: widget.label,
//           labelStyle: TextStyle(color: Colors.grey.shade400),
//           alignLabelWithHint: true,
//           contentPadding: EdgeInsets.all((widget.compact == true ? 10 : 20)),
//         ),
//       ),
//     );
//   }
// }

// class MelodicaPhoneField extends StatefulWidget {
//   final bool compact;
//   final bool dark;
//   final String label;
//   final Map<String, dynamic>? selectedCountryCode;
//   final Map<String, dynamic>? selectedAreaCode;
//   final String? selectedNumber;
//   final Function(
//     Map<String, dynamic> code,
//     Map<String, dynamic>? area,
//     String end,
//   )?
//   onChange;

//   const MelodicaPhoneField({
//     super.key,
//     //required this.controller,
//     this.dark = false,
//     this.compact = true,
//     this.label = "...",
//     this.selectedNumber,
//     this.selectedCountryCode,
//     this.selectedAreaCode,
//     this.onChange,
//   });

//   @override
//   State<MelodicaPhoneField> createState() => _MelodicaPhoneFieldState();
// }

// class _MelodicaPhoneFieldState extends State<MelodicaPhoneField> {
//   TextEditingController controller = TextEditingController();
//   Map<String, dynamic> code = {};
//   Map<String, dynamic>? area;
//   List<Map<String, dynamic>> _countrycodes = [];
//   List<Map<String, dynamic>> _uaeAreaCodes = [];
//   Map<String, dynamic> _uae = {};

//   @override
//   void initState() {
//     super.initState();
//     _countrycodes = Dynamics.countryCodes
//         .map(
//           (e) => {
//             "name": e["mc_name"],
//             "maxlength": e["mc_length"],
//             "country": e["mc_Country"]["mc_name"],
//             "value": e["mc_countrycodeid"],
//             "countryvalue": e["mc_countryid"],
//           },
//         )
//         .toList();
//     _countrycodes.sort(
//       (a, b) => a["country"].toString().compareTo(b["country"].toString()),
//     );

//     _uaeAreaCodes = Dynamics.areaCodes
//         .map(
//           (e) => {
//             "name": e["value"],
//             "displayorder": e["displayorder"],
//             "value": e["attributevalue"],
//           },
//         )
//         .toList();
//     _uaeAreaCodes.sort(
//       (a, b) =>
//           a["displayorder"].toString().compareTo(b["displayorder"].toString()),
//     );

//     // _uae = _countrycodes.firstWhere((e) {
//     //   log(e["name"]);
//     //   return e["name"] == "971";
//     // });

//     // country code init
//     if (widget.selectedCountryCode != null) {
//       code = _countrycodes.firstWhere((e) {
//         return e["name"] == widget.selectedCountryCode!["name"]!;
//       });
//     } else {
//       code = _uae;
//     }

//     // area code init
//     if (widget.selectedAreaCode != null && code == _uae) {
//       area = _uaeAreaCodes.firstWhere((e) {
//         return e["name"] == widget.selectedAreaCode!["name"]!;
//       });
//     } else {
//       area = _uaeAreaCodes.first;
//     }

//     // phone number init
//     if (widget.selectedNumber != null) {
//       var inputMobile = widget.selectedNumber!;

//       if (widget.selectedCountryCode != null) {
//         inputMobile = inputMobile.replaceFirst(code["name"], "");
//         if (widget.selectedAreaCode != null && code == _uae) {
//           inputMobile = inputMobile.replaceFirst(area!["name"], "");
//         }
//       } else {
//         log(area!["name"]);
//         inputMobile = inputMobile.substring(inputMobile.length);
//         log(inputMobile);
//       }

//       controller.text = inputMobile;
//     }

//     controller.addListener(() {
//       var codelength = code["name"].length;
//       var arealength = code == _uae ? area!["name"].length : 0;
//       var totallength = (codelength + arealength + controller.text.length);

//       if (code["maxlength"] <= totallength) {
//         Common.errorMessage(context, "Phone number length is too long.");
//       }

//       if (widget.onChange != null) {
//         setState(() {
//           widget.onChange!(code, area, controller.text);
//         });
//       }
//     });

//     // we run this now to initialize the output variables for the targeting states
//     area = code == _uae ? area ?? _uaeAreaCodes.first : null;
//     if (widget.onChange != null) {
//       widget.onChange!(code, area, controller.text);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10),
//       child: Row(
//         children: [
//           SizedBox(
//             height: 48,
//             width: 80,
//             child: MelodicaDropDownAlt(
//               label: "Code",
//               items: _countrycodes,
//               defaultSelection: code,
//               compact: widget.compact,
//               rightround: false,
//               onChange: (value) {
//                 setState(() {
//                   code = value;
//                   area = code == _uae ? area ?? _uaeAreaCodes.first : null;
//                   if (widget.onChange != null) {
//                     widget.onChange!(code, area, controller.text);
//                   }
//                 });
//               },
//             ),
//           ),
//           Visibility(
//             visible: code == _uae,
//             child: SizedBox(
//               height: 48,
//               width: 80,
//               child: MelodicaDropDownAlt(
//                 label: "Area",
//                 items: _uaeAreaCodes,
//                 defaultSelection: area ?? {},
//                 compact: widget.compact,
//                 leftround: false,
//                 rightround: false,
//                 onChange: (value) {
//                   setState(() {
//                     area = value;
//                     if (widget.onChange != null) {
//                       widget.onChange!(code, area, controller.text);
//                     }
//                   });
//                 },
//               ),
//             ),
//           ),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               keyboardType: TextInputType.phone,
//               style: TextStyle(
//                 color: widget.dark
//                     ? Colors.grey.shade100
//                     : Colors.grey.shade800,
//               ),
//               decoration: InputDecoration(
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: widget.dark
//                         ? Colors.grey.shade600
//                         : Colors.grey.shade400,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomRight: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: MelodicaTheme.primary),
//                   borderRadius: const BorderRadius.only(
//                     bottomRight: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 fillColor: widget.dark ? Colors.grey.shade700 : Colors.white,
//                 filled: true,
//                 labelText: widget.label,
//                 labelStyle: TextStyle(
//                   color: widget.dark
//                       ? Colors.grey.shade100
//                       : Colors.grey.shade400,
//                 ),
//                 alignLabelWithHint: true,
//                 contentPadding: EdgeInsets.all(
//                   (widget.compact == true ? 10 : 20),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MelodicaMenuItem extends StatelessWidget {
//   final Function()? menuItemOnTap;
//   final String menuItemLabel;
//   final IconData menuItemIcon;

//   const MelodicaMenuItem({
//     super.key,
//     required this.menuItemLabel,
//     required this.menuItemIcon,
//     required this.menuItemOnTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: menuItemOnTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//         child: Align(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25,
//                   vertical: 0,
//                 ),
//                 child: Icon(
//                   menuItemIcon,
//                   size: 30,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               Text(
//                 menuItemLabel,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: Icon(Icons.chevron_right, color: Colors.grey.shade700),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // class MelodicaDateField extends StatefulWidget {
// //   MelodicaDateField({super.key, this.callback});
// //   void Function(DateTime selectedDate)? callback;
// //   @override
// //   State<MelodicaDateField> createState() => _MelodicaDateFieldState();
// // }

// // class _MelodicaDateFieldState extends State<MelodicaDateField> {
// //   DateTime? _selectedDateofBirth;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(top: 10),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             "Student's date of birth (optional)",
// //             style: TextStyle(color: Colors.grey.shade700),
// //           ),
// //           GestureDetector(
// //             onTap: () {
// //               Common.showCustomDialog(
// //                 context,
// //                 Column(
// //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                   children: [
// //                     Padding(
// //                       padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
// //                       child: Text(
// //                         "Use the slides to select a date",
// //                         textAlign: TextAlign.center,
// //                         style: TextStyle(
// //                           color: Colors.grey.shade700,
// //                           fontSize: 18,
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(
// //                       height: 200,
// //                       child: CupertinoDatePicker(
// //                         mode: CupertinoDatePickerMode.date,
// //                         initialDateTime: DateTime.now(),
// //                         dateOrder: DatePickerDateOrder.dmy,
// //                         onDateTimeChanged: (DateTime newDateTime) {
// //                           _selectedDateofBirth = newDateTime.toLocal();
// //                         },
// //                       ),
// //                     ),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                       children: [
// //                         MelodicaButton(
// //                           buttonText: "Cancel",
// //                           onTap: () {
// //                             Navigator.pop(context);
// //                           },
// //                           compact: true,
// //                         ),
// //                         MelodicaButton(
// //                           buttonText: "OK",
// //                           onTap: () {
// //                             setState(() {
// //                               if (widget.callback != null &&
// //                                   _selectedDateofBirth != null) {
// //                                 widget.callback!(_selectedDateofBirth!);
// //                               }
// //                             });
// //                             Navigator.pop(context);
// //                           },
// //                           compact: true,
// //                           primary: true,
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //             child: Padding(
// //               padding: const EdgeInsets.only(top: 5),
// //               child: Container(
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   border: Border.all(color: Colors.grey.shade200),
// //                 ),
// //                 padding: EdgeInsets.all((true == true ? 10 : 25)),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       child: Text(
// //                         '${_selectedDateofBirth != null ? DateFormat("EEEE, MMM d, yyyy").format(_selectedDateofBirth!) : ""}',
// //                       ),
// //                     ),
// //                     Icon(
// //                       Icons.calendar_month_sharp,
// //                       color: Colors.grey.shade700,
// //                     )
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class MelodicaButton extends StatelessWidget {
//   final String buttonText;
//   final Function()? onTap;
//   final bool compact;
//   final Color? colour;
//   final Color? textColour;

//   const MelodicaButton({
//     super.key,
//     required this.onTap,
//     required this.buttonText,
//     this.compact = false,
//     this.colour,
//     this.textColour,
//   });

//   @override
//   Widget build(BuildContext context) {
//     //var colorScheme = Theme.of(context).colorScheme;
//     var colours = colour ?? Colors.grey.shade900;
//     var textColours = textColour ?? Colors.white;
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: 5,
//             vertical: (compact ? 5 : 15),
//           ),
//           margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
//           decoration: BoxDecoration(
//             color: colour,
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(50),
//             // boxShadow: [
//             //   BoxShadow(
//             //     blurRadius: 10,
//             //     color: Colors.grey.shade300,
//             //     blurStyle: BlurStyle.outer,
//             //   ),
//             // ],
//           ),
//           child: Center(
//             child: Text(
//               buttonText,
//               style: TextStyle(
//                 color: textColour,
//                 fontWeight: FontWeight.bold,
//                 fontSize: (compact ? 16 : 20),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MelodicaContentContainer extends StatelessWidget {
//   final List<Widget> children;
//   final MainAxisAlignment mainAxisAlignment;
//   final CrossAxisAlignment crossAxisAlignment;
//   const MelodicaContentContainer({
//     super.key,
//     required this.children,
//     this.mainAxisAlignment = MainAxisAlignment.start,
//     this.crossAxisAlignment = CrossAxisAlignment.center,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: mainAxisAlignment,
//           crossAxisAlignment: crossAxisAlignment,
//           children: children,
//         ),
//       ),
//     );
//   }
// }

// class MelodicaPageDivider extends StatelessWidget {
//   const MelodicaPageDivider({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
//       child: Divider(thickness: 0.5, color: Colors.grey.shade400),
//     );
//   }
// }

// class MelodicaDropDown extends StatefulWidget {
//   final String label;
//   final List<dynamic> items;
//   final void Function(dynamic value) onChange;
//   final Map<String, dynamic> defaultSelection;
//   final Widget? onNew;
//   const MelodicaDropDown({
//     super.key,
//     required this.label,
//     required this.items,
//     required this.onChange,
//     required this.defaultSelection,
//     this.onNew,
//   });

//   @override
//   State<MelodicaDropDown> createState() => _MelodicaDropDownState();
// }

// class _MelodicaDropDownState extends State<MelodicaDropDown> {
//   var _selected = -1;
//   @override
//   void initState() {
//     super.initState();
//     for (var i = 0; i < widget.items.length; i++) {
//       if (widget.items[i] == widget.defaultSelection) {
//         _selected = i;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(50),
//       ),
//       padding: const EdgeInsets.all(2),
//       //margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Text(
//               widget.label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade400),
//                 borderRadius: BorderRadius.circular(50),
//                 color: MelodicaTheme.primary,
//               ),
//               padding: EdgeInsets.zero,
//               margin: EdgeInsets.zero,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         Common.showCustomDialog(
//                           context,
//                           height: 600,
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 10,
//                             ),
//                             child: SingleChildScrollView(
//                               child: Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: List.generate(
//                                     widget.items.length +
//                                         (widget.onNew == null ? 0 : 1),
//                                     (index) {
//                                       return GestureDetector(
//                                         onTap: () {
//                                           if (widget.onNew != null &&
//                                               widget.items.length == index) {
//                                             Navigator.pop(context);
//                                             Common.goToPage(
//                                               context,
//                                               widget.onNew!,
//                                               // ProfileNewRelationPage(
//                                               //   onCreate: (value) {
//                                               //     setState(() {
//                                               //       _selected = index;
//                                               //       widget.onChange(value);
//                                               //     });
//                                               //   },
//                                               // ),
//                                             );
//                                           } else {
//                                             setState(() {
//                                               _selected = index;
//                                               widget.onChange(
//                                                 widget.items[index],
//                                               );
//                                             });
//                                             Navigator.pop(context);
//                                           }
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 20,
//                                             vertical: 10,
//                                           ),
//                                           child: Text(
//                                             widget.items.length == index
//                                                 ? "ADD NEW +"
//                                                 : widget.items[index]["name"],
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18,
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Text(
//                           _selected >= 0 ? widget.items[_selected]["name"] : "",
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border(
//                         left: BorderSide(
//                           color: Colors.grey.shade400,
//                           width: 0.5,
//                         ),
//                       ),
//                     ),
//                     child: const Column(children: [Icon(Icons.unfold_more)]),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MelodicaDropDownAlt extends StatefulWidget {
//   final String label;
//   final List<dynamic> items;
//   final void Function(dynamic) onChange;
//   final Map<String, dynamic> defaultSelection;
//   final bool compact;
//   final bool leftround;
//   final bool rightround;
//   final EdgeInsetsGeometry? margin;
//   const MelodicaDropDownAlt({
//     super.key,
//     required this.label,
//     required this.items,
//     required this.onChange,
//     required this.defaultSelection,
//     this.compact = false,
//     this.leftround = true,
//     this.rightround = true,
//     this.margin,
//   });

//   @override
//   State<MelodicaDropDownAlt> createState() => _MelodicaDropDownAltState();
// }

// class _MelodicaDropDownAltState extends State<MelodicaDropDownAlt> {
//   var _selected = -1;
//   @override
//   void initState() {
//     super.initState();
//     for (var i = 0; i < widget.items.length; i++) {
//       if (widget.items[i].toString() == widget.defaultSelection.toString()) {
//         _selected = i;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Common.showCustomDialog(
//           context,
//           height: 600,
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: SingleChildScrollView(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: List.generate(widget.items.length, (index) {
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selected = index;
//                           widget.onChange(widget.items[index]);
//                         });
//                         Navigator.pop(context);
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10,
//                         ),
//                         child: Text(
//                           widget.items[index]["name"].toString(),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//       child: Container(
//         margin: widget.margin,
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: widget.leftround
//                       ? const Radius.circular(20)
//                       : Radius.zero,
//                   topLeft: widget.leftround
//                       ? const Radius.circular(20)
//                       : Radius.zero,
//                   bottomRight: widget.rightround
//                       ? const Radius.circular(20)
//                       : Radius.zero,
//                   topRight: widget.rightround
//                       ? const Radius.circular(20)
//                       : Radius.zero,
//                 ),
//                 color: Colors.white,
//                 border: Border.all(color: Colors.grey.shade400),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               margin: EdgeInsets.zero,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: Text(
//                         _selected >= 0 ? widget.items[_selected]["name"] : "",
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border(
//                         left: BorderSide(
//                           color: Colors.grey.shade400,
//                           width: 0.5,
//                         ),
//                       ),
//                     ),
//                     child: const Column(
//                       children: [Icon(Icons.keyboard_arrow_down)],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: -10,
//               left: 5,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(50),
//                   color: Colors.white,
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 5),
//                 child: Text(
//                   widget.label,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade400,
//                     fontSize: widget.compact ? 12 : 14,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MelodicaTwoOptions extends StatefulWidget {
//   final String label;
//   final List<Map<String, dynamic>> items;
//   final void Function(dynamic value) onChange;
//   final Map<String, dynamic> defaultSelection;
//   const MelodicaTwoOptions({
//     super.key,
//     required this.label,
//     required this.items,
//     required this.onChange,
//     required this.defaultSelection,
//   });

//   @override
//   State<MelodicaTwoOptions> createState() => _MelodicaTwoOptionsState();
// }

// class _MelodicaTwoOptionsState extends State<MelodicaTwoOptions> {
//   var _selected = -1;
//   @override
//   void initState() {
//     super.initState();
//     for (var i = 0; i < widget.items.length; i++) {
//       if (widget.items[i] == widget.defaultSelection) {
//         _selected = i;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 5),
//       child: Column(
//         children: [
//           Text(
//             widget.label,
//             style: TextStyle(
//               color: Colors.grey.shade400,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(50),
//                 ),
//                 padding: const EdgeInsets.all(2),
//                 margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
//                 child: Row(
//                   children: List.generate(widget.items.length, (index) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(50),
//                         color: _selected == index
//                             ? Colors.white
//                             : Colors.transparent,
//                       ),
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _selected = index;
//                             widget.onChange(widget.items[index]);
//                           });
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 15),
//                           child: Text(widget.items[index]["name"]),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // class SelectableGrid extends StatelessWidget {
// //   final Function(Function()) setState;
// //   String selectedValue;
// //   final List<SelectableGridItem> gridOptions;
// //   SelectableGrid({
// //     super.key,
// //     required this.setState,
// //     required this.selectedValue,
// //     required this.gridOptions,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     List<Widget> gridItems = [];
// //     //gridOptions.forEach((gridOption) {   });
// //     gridOptions.forEach((gridOption) {
// //       gridItems.add(
// //         GestureDetector(
// //           onTap: () {
// //             setState(
// //               () {
// //                 selectedValue = gridOption.label;
// //               },
// //             );
// //           },
// //           child: Padding(
// //             padding: const EdgeInsets.all(10),
// //             child: gridOption,
// //           ),
// //         ),
// //       );
// //     });

// //     return SizedBox(
// //       height: MediaQuery.of(context).size.width > 450 ? 150 : 270,
// //       child: GridView.count(
// //         crossAxisCount: MediaQuery.of(context).size.width > 450 ? 6 : 3,
// //         scrollDirection: Axis.vertical,
// //         children: gridItems,
// //         //  [
// //         //   SelectableGridItem(
// //         //     icon: Icons.music_note,
// //         //     label: "Music",
// //         //     onTap: setState,
// //         //   ),
// //         //   SelectableGridItem(
// //         //     icon: Icons.sports_martial_arts,
// //         //     label: "Dance",
// //         //     onTap: setState,
// //         //   ),
// //         //   SelectableGridItem(
// //         //     icon: Icons.store,
// //         //     label: "Shopping",
// //         //     onTap: setState,
// //         //   ),
// //         //   SelectableGridItem(
// //         //     icon: Icons.engineering,
// //         //     label: "Service",
// //         //     onTap: setState,
// //         //   ),
// //         //   SelectableGridItem(
// //         //     icon: Icons.work_outlined,
// //         //     label: "Career",
// //         //     onTap: setState,
// //         //   ),
// //         //   SelectableGridItem(
// //         //     icon: Icons.support_agent,
// //         //     label: "Support",
// //         //     onTap: setState,
// //         //   ),
// //         // ],
// //       ),
// //     );
// //   }
// // }

// // class SelectableGridItem extends StatefulWidget {
// //   final IconData icon;
// //   final String label;

// //   SelectableGridItem({
// //     super.key,
// //     required this.icon,
// //     required this.label,
// //   });

// //   @override
// //   State<SelectableGridItem> createState() => _SelectableGridItemState();
// // }

// // class _SelectableGridItemState extends State<SelectableGridItem> {
// //   String? selectedValue;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       alignment: Alignment.center,
// //       decoration: BoxDecoration(
// //         color: selectedValue == widget.label ? MelodicaTheme.primary : Colors.white70,
// //         // gradient: LinearGradient(
// //         //   colors: [
// //         //     Color(0xFFFFCB05),
// //         //     MelodicaTheme.primary,
// //         //     Color(0xFFFFCB05),
// //         //   ],
// //         //   begin: Alignment.topLeft,
// //         // ),
// //         border: Border.all(
// //           color: Colors.white,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             blurRadius: 10,
// //             blurStyle: BlurStyle.outer,
// //             color: Colors.grey.shade300,
// //           ),
// //         ],
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             widget.icon,
// //             size: 40,
// //             color: Colors.grey.shade600,
// //           ),
// //           Text(
// //             widget.label,
// //             style: TextStyle(
// //               fontSize: 15,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.grey.shade600,
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }

// class MelodicaPackagePill extends StatelessWidget {
//   final String package;
//   final double width;
//   const MelodicaPackagePill({
//     super.key,
//     required this.package,
//     required this.width,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       right: width,
//       left: width,
//       top: -10,
//       child: Container(
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           //border: Border.all(color: Colors.grey.shade600),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.shade300,
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//               spreadRadius: 1,
//             ),
//           ],
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(50),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             colors: [
//               package == "Basic"
//                   ? const Color(0xFF8A5631)
//                   : package == "Silver"
//                   ? Colors.grey.shade200
//                   : package == "Gold"
//                   ? Colors.yellow.shade500
//                   : package == "Platinum"
//                   ? Colors.grey.shade500
//                   : Colors.transparent,
//               package == "Basic"
//                   ? const Color(0xFFDBA074)
//                   : package == "Silver"
//                   ? Colors.grey.shade400
//                   : package == "Gold"
//                   ? Colors.yellow.shade800
//                   : package == "Platinum"
//                   ? Colors.grey.shade800
//                   : Colors.transparent,
//             ],
//           ),
//         ),
//         child: Text(
//           package,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: package == "Platinum" || package == "Basic"
//                 ? Colors.white
//                 : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MelodicaPackagePills extends StatelessWidget {
//   final String package;
//   const MelodicaPackagePills({super.key, required this.package});

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: -10,
//       left: 50,
//       child: Container(
//         width: 100,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//         decoration: BoxDecoration(
//           //border: Border.all(color: Colors.grey.shade600),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.shade300,
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//               spreadRadius: 1,
//             ),
//           ],
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(50),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             colors: [
//               package == "Basic"
//                   ? Colors.white
//                   : package == "Silver"
//                   ? Colors.grey.shade200
//                   : package == "Gold"
//                   ? Colors.yellow.shade500
//                   : package == "Platinum"
//                   ? Colors.grey.shade500
//                   : Colors.transparent,
//               package == "Basic"
//                   ? Colors.grey.shade100
//                   : package == "Silver"
//                   ? Colors.grey.shade400
//                   : package == "Gold"
//                   ? Colors.yellow.shade600
//                   : package == "Platinum"
//                   ? Colors.grey.shade800
//                   : Colors.transparent,
//             ],
//           ),
//         ),
//         child: Text(
//           package,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: package == "Platinum" ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CustomShape extends CustomClipper<Path> {
//   double _curve = 50;
//   CustomShape(double curve) {
//     _curve = curve;
//   }

//   @override
//   Path getClip(Size size) {
//     double height = size.height;
//     double width = size.width;

//     var path = Path();
//     path.lineTo(0, height - _curve);
//     path.quadraticBezierTo(width / 2, height + _curve, width, height - _curve);
//     path.lineTo(width, 0);

//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }

const String privacypolicy =
    "https://studentsportal.melodica.ae/privacy-policy/";
const String termscondition =
    "https://studentsportal.melodica.ae/terms-conditions/";
