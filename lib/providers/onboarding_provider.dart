import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  PageController pageController = PageController();
  int _page = 0;
  int get page => _page;

  void setPage(int p) {
    _page = p;
    notifyListeners();
  }

  void nextPage() {
    if (_page < 3) {
      final next = _page + 1;
      print('next $next');
      _page = next; // ✅ update state first
      print('_page $_page');
      notifyListeners(); // ✅ notify dots immediately

      pageController.animateToPage(
        next,
        duration: Duration(milliseconds: 450),
        curve: Curves.ease,
      );
      notifyListeners();
    }
  }
}
