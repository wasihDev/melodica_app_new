import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class AppstateProvider extends ChangeNotifier {
  bool _isFirstLaunch = true;
  bool isFromSplash = true;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool get isFirstLaunch => _isFirstLaunch;
  bool userLoggedIn = false;

  Future<void> initAppState() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = await prefs.getBool('isFirstLaunchs') ?? true;
    userLoggedIn = await prefs.getBool('userLoggedIn') ?? false;
    isFromSplash = await prefs.getBool('isFromSplash') ?? false;
    print("isFromSplash =======>>>> ${isFromSplash}");
    await Future.delayed(const Duration(seconds: 2), () {});
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = await prefs.setBool('isFirstLaunchs', false);
    notifyListeners();
  }

  Future<void> setLoggedIn(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('userLoggedIn', loggedIn);
    userLoggedIn = loggedIn;
    notifyListeners();
  }

  Future<void> setisFromSplash(bool isFromsplash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFromSplash', isFromsplash);
    isFromsplash = isFromsplash;
    notifyListeners();
  }
}
