import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  int _page = 0;
  int get page => _page;

  void setPage(int p) {
    _page = p;
    notifyListeners();
  }

  void nextPage() {
    if (_page < 3) {
      pageController.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.ease,
      );
      notifyListeners();
    }
  }
}
