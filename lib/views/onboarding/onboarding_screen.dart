import 'dart:io';

import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/appstate_provider.dart';
// import 'package:melodica_app_new/providers/onboarding_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController = PageController();
  int _currentIndex = 0;

  bool isShowLogin = false;
  // Developer requested the uploaded image path be used as-is. That path is:
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> _pages = [
      {
        'title': "Welcome Melodica\nMusic & Dance Academy",
        'image': 'assets/images/ob1.png',
      },
      {
        'title': "Learn Music.\nLearn Dance. Be Inspired.",
        'image': 'assets/images/ob3.png',
      },
      {
        'title':
            "Where students discover\nconfidence, passion, and\nperformance.",
        'image': 'assets/images/ob2.png',
      },
    ];
    // final provider = Provider.of<OnboardingProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFF333333), // dark frame like the design
      body: SafeArea(
        top: false,
        bottom: Platform.isIOS ? false : true,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                pageSnapping: true,
                controller: pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  // print('index $index');
                  return isShowLogin
                      ? _buildFinalPage(
                          context,
                          imagePath: 'assets/images/ob4.png',
                        )
                      : Container(
                          // height: 50.h,
                          // width: 50.w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              alignment: Alignment.topCenter,
                              image: AssetImage(item['image']!),
                            ),
                          ),
                          // child: Image.asset(
                          //   // fit: BoxFit.cover,
                          //   errorBuilder: (c, e, s) => Container(
                          //     color: Colors.grey.shade200,
                          //     child: Center(
                          //       child: Image.asset('assets/placeholder_bg.jpg'),
                          //     ),
                          //   ),
                          // ),
                        );
                },
              ),
            ),

            isShowLogin
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      // height: MediaQuery.of(context).size.height * 0.28,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 30,
                      ),
                      child: Consumer<AppstateProvider>(
                        builder: (context, providers, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text(
                                'Book. Track. Learn.\nAll in One Place',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  side: const BorderSide(color: Colors.black87),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                                onPressed: () {
                                  providers.completeFirstLaunch();
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                                onPressed: () {
                                  providers.completeFirstLaunch();
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.signup,
                                  );
                                },
                                child: const Text(
                                  'Signup',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.34,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentIndex == 0
                                ? "Welcome\nMelodica Music & Dance\nAcademy"
                                : _currentIndex == 1
                                ? "Learn Music.\nLearn Dance. Be Inspired."
                                : "Where students discover\nconfidence, passion, and\nperformance.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20.fSize,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_pages.length, (index) {
                              // final isActive = ;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _currentIndex == index ? 36 : 10,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentIndex == index
                                      ? Colors.white
                                      : Colors.white70,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _currentIndex == index
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.15,
                                            ),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : null,
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 18.h),
                          // _NextButton(),
                          InkWell(
                            onTap: () {
                              if (_currentIndex < _pages.length - 1) {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.linear,
                                );
                              } else {
                                setState(() {
                                  isShowLogin = true;
                                });
                                print('object');
                              }
                              // if (provider.page < 3) {
                              //   provider.nextPage();
                              // } else {
                              //   print('nothing for now ');
                              // }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Next',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalPage(BuildContext context, {required String imagePath}) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/ob4.png',
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
          ),
        ),
      ],
    );
  }
}
