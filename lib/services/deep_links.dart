// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:melodica_app_new/providers/services_provider.dart';
// import 'package:melodica_app_new/routes/routes.dart';
// import 'package:melodica_app_new/views/dashboard/home/checkout/checkout_screen.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:provider/provider.dart';

// class DeepLinkService {
//   final AppLinks _appLinks = AppLinks();

//   void init(BuildContext) {
//     _appLinks.getInitialLink().then(_handleUri);
//     _appLinks.uriLinkStream.listen(_handleUri);
//   }

//   Future<void> _handleUri(Uri? uri) async {
//     debugPrint('uri =====>>> $uri');
//     if (uri == null) return;

//     if (uri.scheme != 'https' || uri.host != 'melodica-mobile.web.app') return;

//     final ref = uri.queryParameters['ref'];
//     if (ref == null || ref.isEmpty) return;

//     /// 🔥 WAIT until context is available
//     await _waitForContext();

//     final context = navigatorKey.currentContext;
//     if (context == null) return;

//     final success = await context.read<ServicesProvider>().installOrder(
//       context,
//       ref: ref,
//     );

//     if (success) {
//       navigatorKey.currentState?.push(
//         MaterialPageRoute(builder: (_) => CheckoutScreen()),
//       );
//     }
//   }

//   /// Wait until MaterialApp is ready
//   Future<void> _waitForContext() async {
//     int retry = 0;
//     while (navigatorKey.currentContext == null && retry < 20) {
//       await Future.delayed(const Duration(milliseconds: 100));
//       retry++;
//     }
//   }

//   // Future<void> _handleUri(Uri? uri) async {
//   //   print('uri =====>>> ${uri}');
//   //   if (uri == null) return;

  //   if (uri.scheme == 'https' && uri.host == 'melodica-mobile.web.app') {
  //     final ref = uri.queryParameters['ref'];

  //     if (ref != null && ref.isNotEmpty) {
  //       final installOrderFinallCall = await navigatorKey.currentContext!
  //           .read<ServicesProvider>()
  //           .installOrder(navigatorKey.currentContext!, ref: ref);
  //       // if the install order is called true navigate to recieot screen
  //       if (installOrderFinallCall) {
  //         Navigator.push(
  //           navigatorKey.currentContext!,
  //           MaterialPageRoute(builder: (_) => CheckoutScreen()),
  //         );
  //       }
  //     }
  //   }
  // }
// }
