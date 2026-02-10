// signup_screen.dart
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/appstate_provider.dart';
import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/utils/common.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:melodica_app_new/utils/validator.dart';
import 'package:melodica_app_new/widgets/common_textfield.dart';
import 'package:melodica_app_new/widgets/custom_button.dart';
import 'package:melodica_app_new/widgets/loading_indicator_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _agree = false;
  // bool _obscure = true;
  // bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // main white body with curved yellow header
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // top curved yellow area
                  Container(
                    height: 260.h,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(36),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 24, left: 12),
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        SizedBox(height: 38.h),
                        Navigator.of(context).canPop()
                            ? Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).maybePop(),
                                    icon: const Icon(Icons.arrow_back_ios),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                              )
                            : SizedBox(),
                        SizedBox(height: 30.h),
                        Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 25.fSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Let’s Start the journey",
                          style: TextStyle(
                            fontSize: 14.fSize,
                            color: Colors.black54,
                          ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 28),
                            // TextFormField(
                            //   controller: _nameCtrl,
                            //   decoration: const InputDecoration(
                            //     labelText: 'Name',
                            //     prefixIcon: Icon(Icons.person),
                            //   ),
                            //   validator: (v) =>
                            //       (v ?? '').trim().isEmpty ? 'Enter name' : null,
                            // ),
                            CommonTextField(
                              heading: "Name",
                              controller: _nameCtrl,
                              wigdet: const Icon(
                                Icons.alternate_email_rounded,
                                color: AppColors.secondPrimary,
                              ),
                              hintText: 'xyz',
                              validator: Validator.validateName,
                            ),
                            const SizedBox(height: 12),
                            CommonTextField(
                              heading: "Email",
                              controller: _emailCtrl,
                              wigdet: const Icon(
                                Icons.person,
                                color: AppColors.secondPrimary,
                              ),
                              hintText: 'Ex.abc#example.com',
                              validator: Validator.validateEmail,
                            ),

                            const SizedBox(height: 12),

                            CommonTextField(
                              heading: "Password",
                              controller: _passCtrl,
                              obscureText: true,
                              isShowSuffix: true,
                              wigdet: const Icon(
                                Icons.lock_outline,
                                color: AppColors.secondPrimary,
                              ),
                              hintText: '********',
                              validator: Validator.validatePassword,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _agree,
                                  onChanged: (v) => setState(() {
                                    _agree = v ?? false;
                                  }),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'I agree to the ',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: const TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchUrl(privacypolicy);
                                            },
                                        ),
                                        const TextSpan(text: ' & '),
                                        TextSpan(
                                          text: 'Terms of Use',
                                          style: const TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchUrl(termscondition);
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Consumer<AuthProviders>(
                              builder: (context, provider, child) {
                                // if (provider.isLoading == true) {
                                // return LoadingIndicatorWideget();
                                // } else {
                                return CustomButton(
                                  isLoading: provider.isLoading,
                                  onTap: () async {
                                    if (_form.currentState!.validate()) {
                                      if (_agree == false) {
                                        SnackbarUtils.showInfo(
                                          context,
                                          "Please accept our terms.",
                                        );
                                      }
                                      await provider.registrationFunc(
                                        context,
                                        email: _emailCtrl.text.trim(),
                                        password: _passCtrl.text.trim(),
                                        name: _nameCtrl.text.trim(),
                                      );
                                      if (context.mounted) {
                                        print('check');
                                        final appState =
                                            Provider.of<AppstateProvider>(
                                              context,
                                              listen: false,
                                            );
                                        appState.setLoggedIn(true);
                                      }
                                      print('chec22k');
                                    }
                                  },
                                  widget: provider.isLoading
                                      ? CircularProgressIndicator(
                                          color: Colors.black,
                                        )
                                      : Text(
                                          "Sign up",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.fSize,
                                            color: AppColors.black,
                                          ),
                                        ),
                                );
                                // }
                              },
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: Text(
                                'Or sign up with social account',
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
                                        await provider.signInWithGoogle(
                                          context,
                                        );
                                      },
                                      icon: provider.isLoadingGoogle
                                          ? LoadingIndicatorWideget()
                                          : SvgPicture.asset(
                                              'assets/svg/google.svg',
                                            ),
                                    ),
                                    // IconButton(
                                    //   onPressed: () {},
                                    //   icon: SvgPicture.asset(
                                    //     'assets/svg/facebook.svg',
                                    //   ),
                                    // ),
                                    Platform.isIOS
                                        ? IconButton(
                                            onPressed: () async {
                                              await provider.signInWithApple(
                                                context,
                                              );
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
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Already have an account ',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/login'),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
