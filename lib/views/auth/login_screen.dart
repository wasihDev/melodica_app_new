// login_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/appstate_provider.dart';
import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/validator.dart';
import 'package:melodica_app_new/widgets/common_textfield.dart';
import 'package:melodica_app_new/widgets/custom_button.dart';
import 'package:melodica_app_new/widgets/loading_indicator_widget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;
    return Scaffold(
      // backgroundColor: const Color(0xFF333333),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              height: 260.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              padding: const EdgeInsets.only(top: 10, left: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(height: 50.h),
                  // Row(
                  //   children: [
                  //     IconButton(
                  //       onPressed: () => Navigator.of(context).maybePop(),
                  //       icon: const Icon(Icons.arrow_back_ios),
                  //     ),
                  //     const SizedBox(width: 6),
                  //   ],
                  // ),
                  // SizedBox(height: 30.h),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 25.fSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Let's continue the journey",
                    style: TextStyle(fontSize: 14.fSize, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      const SizedBox(height: 28),

                      CommonTextField(
                        heading: "Email",
                        keyboardType: TextInputType.emailAddress,
                        controller: _email,
                        wigdet: const Icon(
                          Icons.person,
                          color: AppColors.secondPrimary,
                        ),
                        hintText: "enter email",
                        errorTitle: "Invalid Email",
                        validator: Validator.validateEmail,
                      ),
                      const SizedBox(height: 12),

                      CommonTextField(
                        heading: "Password",
                        controller: _pass,
                        obscureText: true,
                        isShowSuffix: true,
                        wigdet: const Icon(
                          Icons.lock_outlined,
                          color: AppColors.secondPrimary,
                        ),
                        hintText: '*********',
                        errorTitle: "incorrect password",
                        validator: Validator.validatePassword,
                      ),
                      const SizedBox(height: 18),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 8),

                      Consumer<AuthProviders>(
                        builder: (context, provider, child) {
                          return CustomButton(
                            isLoading: provider.isLoading,
                            //,
                            onTap: () async {
                              if (_form.currentState!.validate()) {
                                print('Form is valid');

                                await provider.loginFunc(
                                  context,
                                  email: _email.text,
                                  password: _pass.text,
                                );
                                if (context.mounted) {
                                  final appState =
                                      Provider.of<AppstateProvider>(
                                        context,
                                        listen: false,
                                      );
                                  appState.setLoggedIn(true);
                                }
                              } else {
                                print('Form is invalid');
                              }

                              // Navigator.pushReplacementNamed(context, '/bottombar');
                            },
                            widget: Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.fSize,
                                color: AppColors.black,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.forget),
                        child: const Text(
                          'Forget Password',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          "Or login with social account",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer<AuthProviders>(
                        builder: (context, provider, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await provider.signInWithGoogle(context);
                                },
                                icon: provider.isLoadingGoogle
                                    ? LoadingIndicatorWideget()
                                    : SvgPicture.asset('assets/svg/google.svg'),
                              ),
                              // IconButton(
                              //   onPressed: () {},
                              //   icon: SvgPicture.asset('assets/svg/facebook.svg'),
                              // ),
                              Platform.isIOS
                                  ? IconButton(
                                      onPressed: () async {
                                        await provider.signInWithApple(context);
                                      },
                                      icon: provider.isLoadingApple
                                          ? LoadingIndicatorWideget()
                                          : SvgPicture.asset(
                                              'assets/svg/apple.svg',
                                            ),
                                    )
                                  : SizedBox(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () => Navigator.of(
                              context,
                            ).pushReplacementNamed('/signup'),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
