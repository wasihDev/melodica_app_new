import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melodica_app_new/firebase_options.dart';
import 'package:melodica_app_new/services/api_config_service.dart';
// import 'package:melodica_app_new/services/deep_links.dart';
import 'package:melodica_app_new/src.dart';
import 'package:melodica_app_new/views/dashboard/notification/services/local_notifications_service.dart';
import 'package:melodica_app_new/views/dashboard/notification/services/notifcaition_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //
  Provider.debugCheckInvalidValueType = null;
  // WidgetsFlutterBinding.ensureInitialized();
  await ApiConfigService.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(
    localNotificationsService: localNotificationsService,
  );

  // DeepLinkService().init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}
