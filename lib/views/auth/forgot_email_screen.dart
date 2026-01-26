// forgot_email_screen.dart
import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/validator.dart';
import 'package:melodica_app_new/views/auth/widgets/back_button.dart';
import 'package:melodica_app_new/widgets/common_textfield.dart';
import 'package:melodica_app_new/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class ForgotEmailScreen extends StatefulWidget {
  const ForgotEmailScreen({super.key});
  @override
  State<ForgotEmailScreen> createState() => _ForgotEmailScreenState();
}

class _ForgotEmailScreenState extends State<ForgotEmailScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  // bool _loading = false;
  // String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final color = AppColors.primary;
    // show email mask as small instruction
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: 340.h,
            width: double.infinity,
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Padding(
              padding: EdgeInsets.only(left: 20.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 70.h),
                  const AppBackButton(),

                  // Text('Forgot Password', style: AppTextStyles.bodyWhiteBold),
                  SizedBox(height: 25.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter you Email for Verification Code",
                        style: TextStyle(
                          fontSize: 25.fSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // SizedBox(height: 15.h),
                      // Text(
                      //   "languages.email_verification",
                      //   // style: AppTextStyles.bodyWhiteSemiRegular,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, .001.h),
            child: Container(
              height: 260.h,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 10.adaptSize),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400]!,

                    blurRadius: 2,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(25.adaptSize),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                child: Consumer(
                  builder: (context, provider, child) {
                    return Form(
                      key: _form,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CommonTextField(
                            heading: "Email",
                            controller: _email,
                            wigdet: const Icon(
                              Icons.alternate_email_rounded,
                              color: AppColors.secondPrimary,
                            ),
                            hintText: 'Ex.abc#example.com',
                            errorTitle: "empty",
                            validator: Validator.validateEmail,
                          ),
                          // custom button
                          Consumer<AuthProviders>(
                            builder: (context, provider, child) {
                              return CustomButton(
                                isLoading: provider.isLoading,
                                // ,
                                onTap: () {
                                  if (_form.currentState!.validate()) {
                                    provider.sendPasswordResetEmail(
                                      context,
                                      _email.text.trim(),
                                    );
                                    _email.clear();
                                  }
                                },
                                widget: Text(
                                  "Send code",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.fSize,
                                    color: AppColors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
