import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/appstate_provider.dart';
import 'package:melodica_app_new/providers/onboarding_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/onboarding/widget/bottom_curve_control.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Developer requested the uploaded image path be used as-is. That path is:
  // /mnt/data/Screenshot 2025-11-25 at 8.02.19 PM.png
  // We'll reference it directly as an Image.file source when running locally.
  // static const String uploadedImagePath =
  //     '/mnt/data/Screenshot 2025-11-25 at 8.02.19 PM.png';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFF333333), // dark frame like the design
      body: Stack(
        children: [
          PageView(
            // physics: NeverScrollableScrollPhysics(),
            pageSnapping: true,
            controller: provider.pageController,
            onPageChanged: (idx) => provider.setPage(idx),
            children: [
              _buildOnboardPage(
                context,
                imagePath: 'assets/images/ob1.png',
                title: 'Welcome to Melodica\nMusic Academy',
              ),
              _buildOnboardPage(
                context,
                imagePath: 'assets/images/ob2.png',
                title: 'Music & Dance Academy',
              ),
              _buildOnboardPage(
                context,
                imagePath: 'assets/images/ob3.png',
                title: 'Largest music instrument\nprovider in the UAE',
              ),
              _buildFinalPage(context, imagePath: 'assets/images/ob1.png'),
            ],
          ),
          // Positioned bottom controls
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomCurveControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardPage(
    BuildContext context, {
    required String imagePath,
    required String title,
  }) {
    return Stack(
      children: [
        // background image - using Image.file to load local file if available
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              color: Colors.grey.shade200,
              child: Center(child: Image.asset('assets/placeholder_bg.jpg')),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(36),
                topRight: Radius.circular(36),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.fSize,
                    color: Colors.black87,
                  ),
                ),
                // SizedBox(height: 20.h),
                const _DotsIndicator(),
                // SizedBox(height: 20.h),
                _NextButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalPage(BuildContext context, {required String imagePath}) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/ob1.png',
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(36),
                topRight: Radius.circular(36),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
            child: Consumer<AppstateProvider>(
              builder: (context, providers, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Get Started',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, prov, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final isActive = prov.page == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 36 : 10,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.white70,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }
}

class _NextButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OnboardingProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        if (prov.page < 3) {
          prov.nextPage();
        } else {
          //
          print('nothing for now ');
        }
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6),
          ],
        ),
        alignment: Alignment.center,
        child: const Text('Next', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
