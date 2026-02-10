import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/utils/common.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:melodica_app_new/views/dashboard/dashboard_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/signature_pad.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
import 'package:melodica_app_new/widgets/summary_row.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  final bool iscomingFromNewStudent;
  const CheckoutScreen({super.key, required this.iscomingFromNewStudent});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ScreenshotController screenshotController = ScreenshotController();

  bool _agreedToTerms = false;
  // String? _selectedPackageId; // Package selected in the middle banner
  String formatFrequency(String value) {
    switch (value.toLowerCase()) {
      case '1 x week':
        return 'Once a week';
      case '2 x week':
        return 'Twice a week';
      default:
        return value; // fallback
    }
  }

  // Future<dynamic> ShowCapturedWidget(
  //   BuildContext context,
  //   Uint8List capturedImage,
  // ) {
  //   return showDialog(
  //     useSafeArea: false,
  //     context: context,
  //     builder: (context) => Scaffold(
  //       appBar: AppBar(title: Text("Captured widget screenshot")),
  //       body: Center(child: Image.memory(capturedImage)),
  //     ),
  //   );
  // }
  void showCapturedImage(BuildContext context, Uint8List image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(10),
        child: InteractiveViewer(child: Image.memory(image)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () async {
                final image = await screenshotController.capture(
                  delay: const Duration(milliseconds: 300),
                  pixelRatio: 3,
                );

                if (image == null) return;

                showCapturedImage(context, image);

                /// Convert to Base64
                final base64Pdf = base64Encode(image);
                // print('base64Pdf $base64Pdf');

                /// Send to API
                // body["orderpdf"] = base64Pdf;
              },
              icon: Icon(Icons.abc_outlined),
            ),
          ],
          leading: Consumer2<ServicesProvider, CustomerController>(
            builder: (context, provider, custPro, child) {
              return IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
                onPressed: () {
                  if (widget.iscomingFromNewStudent) {
                    provider.isStudentNew = false;
                    custPro.clearStudentForm();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                  // provider.clearList();
                },
              );
            },
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          bottom: true,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.h),
                      // --- Product List ---
                      // ProductCard(
                      //   productName: 'Dimension 1 (Piano Classes)',
                      //   dimensions: 'Dimension 2\nDimension 3',
                      //   courseDuration: '48 classes - 45 minutes',
                      //   price: '₫ 1,620',
                      //   onDelete: () => print('Delete 1'),
                      // ),
                      // ProductCard(
                      //   productName: 'Dimension 1 (Piano Classes)',
                      //   dimensions: 'Dimension 2\nDimension 3',
                      //   courseDuration: '48 classes - 45 minutes',
                      //   price: '₫ 1,620',
                      //   onDelete: () => print('Delete 2'),
                      // ),

                      // --- Offer Banner ---
                      // Consumer<ServicesProvider>(
                      //   builder: (context, provider, child) {
                      //     return Text(
                      //       '${provider.selectedPackages}',
                      //       style: TextStyle(
                      //         color: AppColors.secondaryText,
                      //         fontSize: 12,
                      //       ),
                      //     );
                      //   },
                      // ),
                      const SizedBox(height: 8),
                      Consumer<ServicesProvider>(
                        builder: (context, provider, child) {
                          return ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: provider.selectedPackages.length,
                            shrinkWrap: true,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final double discountedPrice =
                                  double.tryParse(
                                    provider.selectedPackages[index].discount
                                        .toString(),
                                  ) ??
                                  0.0;
                              final double sessions = provider
                                  .selectedPackages[index]
                                  .sessions
                                  .toDouble();
                              final discountedAmount =
                                  provider.selectedPackages[index].price *
                                  (discountedPrice / 100);
                              String perClassCost;
                              // ((provider.selectedPackages[index].price -
                              //             discountedAmount) /
                              //         sessions)
                              //     .toStringAsFixed(2);
                              if (provider.tab == "Dance") {
                                perClassCost =
                                    (provider.selectedPackages[index].price /
                                            provider
                                                .selectedPackages[index]
                                                .sessions)
                                        .toStringAsFixed(0);
                              } else {
                                perClassCost =
                                    ((provider.selectedPackages[index].price -
                                                discountedAmount) /
                                            sessions)
                                        .toStringAsFixed(2);
                              }
                              return _buildSilverPackageCard(
                                id: 'checkout_package',
                                title: provider.selectedPackages[index].service,
                                title2: '',
                                unit: provider
                                    .selectedPackages[index]
                                    .sessionstext,
                                duration: provider.tab == "Dance"
                                    ? ""
                                    : "Duration: ${provider.selectedPackages[index].duration} min",
                                details:
                                    'Freezing Weeks: ${provider.selectedPackages[index].freezings == null ? 0 : provider.selectedPackages[index].freezings}',
                                price:
                                    '${provider.selectedPackages[index].price.toString().split('.').first}',
                                pricePerClass:
                                    "$perClassCost per class", // '${(provider.selectedPackages[index].price / provider.selectedPackages[index].sessions).toStringAsFixed(0)} per Class',
                                discount:
                                    '${provider.selectedPackages[index].discount}',
                                onDelete: () => provider.removePackageAt(index),
                                details1:
                                    'Class Cancellations: ${provider.selectedPackages[index].cancellations}',
                                details2:
                                    provider
                                                .selectedPackages[index]
                                                .frequencytext !=
                                            null &&
                                        provider
                                            .selectedPackages[index]
                                            .frequencytext!
                                            .isNotEmpty
                                    ? 'Classes: ${formatFrequency(provider.selectedPackages[index].frequencytext)}'
                                    : '',
                              );
                            },
                          );
                        },
                      ),
                      // const SizedBox(height: 12),

                      // --- Apply Code ---
                      // const Text(
                      //   'Apply Code',
                      //   style: TextStyle(
                      //     color: AppColors.secondaryText,
                      //     fontSize: 14,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: TextField(
                      //         decoration: InputDecoration(
                      //           hintText: '12ASD2s',
                      //           hintStyle: TextStyle(color: Colors.grey[400]),
                      //           filled: true,
                      //           fillColor: AppColors.lightGrey,
                      //           contentPadding: EdgeInsets.symmetric(
                      //             horizontal: 16,
                      //             vertical: 12,
                      //           ),
                      //           border: OutlineInputBorder(
                      //             borderRadius: BorderRadius.all(
                      //               Radius.circular(12),
                      //             ),
                      //             borderSide: BorderSide.none,
                      //           ),
                      //           enabledBorder: OutlineInputBorder(
                      //             borderRadius: BorderRadius.all(
                      //               Radius.circular(12),
                      //             ),
                      //             borderSide: BorderSide.none,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 16),
                      //     SizedBox(
                      //       height: 48,
                      //       child: ElevatedButton(
                      //         onPressed: () => print('Apply code'),
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: AppColors.primary,
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //           ),
                      //           elevation: 0,
                      //         ),
                      //         child: const Text(
                      //           'Apply',
                      //           style: TextStyle(
                      //             color: AppColors.darkText,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // --- Terms and Signature ---
                      Row(
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value!;
                              });
                            },
                            activeColor: AppColors.primary,
                            visualDensity: VisualDensity.compact,
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkText,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _launchUrl(privacypolicy);
                                      },
                                  ),
                                  const TextSpan(text: ' & '),
                                  TextSpan(
                                    text: 'Terms of Use',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
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
                      const SizedBox(height: 16),
                      const Text(
                        'Draw a Signature',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<ServicesProvider>(
                        builder: (context, provider, child) {
                          return SignaturePad(
                            onSave: (bytes) {
                              provider.signatureBytes = bytes;
                              debugPrint('Auto-saved: ${bytes?.length}');
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(content: Text('Signature saved')),
                              // );
                            },
                          );
                        },
                      ),

                      // const SignaturePad(), // Custom Widget Placeholder
                      const SizedBox(height: 5),

                      // --- Payment Summary ---
                      const Text(
                        'Payment Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer<ServicesProvider>(
                        builder: (context, provider, child) {
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            child: Column(
                              children: [
                                SummaryRow(
                                  label: 'Course Fee',
                                  value:
                                      '${provider.totalPrice.toStringAsFixed(2)}',
                                  valueColor: AppColors.darkText,
                                ),
                                SummaryRow(
                                  label: 'Admission Fee',
                                  value: provider.isStudentNew == true
                                      ? '150'
                                      : provider
                                                .customerController
                                                .selectedStudent!
                                                .isregistred ==
                                            'Yes'
                                      ? "0"
                                      : '150',
                                  valueColor: AppColors.darkText,
                                ),
                                SummaryRow(
                                  label: 'Discount',
                                  value:
                                      '${provider.totalDiscount.toStringAsFixed(2)}',
                                  valueColor: AppColors.redError,
                                ), // Assuming red for negative
                                SummaryRow(
                                  label: 'VAT',
                                  value:
                                      '${provider.vatAmount.toStringAsFixed(2)}',
                                  valueColor: AppColors.darkText,
                                ),
                                const Divider(
                                  color: AppColors.lightGrey,
                                  thickness: 1,
                                  height: 20,
                                ),
                                SummaryRow(
                                  label: 'Total',
                                  value: widget.iscomingFromNewStudent == true
                                      ? "${(provider.payableAmount + 150).toStringAsFixed(2)}"
                                      : '${provider.customerController.selectedStudent!.isregistred == 'Yes' ? provider.payableAmount : "${(provider.payableAmount + 150).toStringAsFixed(2)}"}',
                                  valueColor: AppColors.redError,
                                  labelWeight: FontWeight.bold,
                                  valueWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // --- Fixed Bottom Button ---
              SafeArea(
                bottom: Platform.isIOS ? false : true,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    // bottom: 24,
                    top: 12,
                  ),
                  child: Consumer<ServicesProvider>(
                    builder: (context, checkout, state) {
                      return PrimaryButton(
                        text: checkout.loading == true
                            ? "Please wait..."
                            : 'Payment',
                        onPressed: () async {
                          if (checkout.signatureBytes == null) {
                            SnackbarUtils.showError(
                              context,
                              "Signature is required to proceed with the payment.",
                            );
                            return;
                          }
                          if (_agreedToTerms == false) {
                            SnackbarUtils.showError(
                              context,
                              "Please agree to the terms and conditions.",
                            );
                            return;
                          }

                          checkout.setPaymentType(PaymentType.packagesOrder);

                          final success = await checkout.startCheckout(
                            context,
                            amount: widget.iscomingFromNewStudent == true
                                ? checkout.payableAmount + 150
                                : checkout
                                      .customerController
                                      .selectedStudent!
                                      .isregistred
                                      .contains('Yes')
                                ? checkout.payableAmount
                                : checkout.payableAmount + 150,
                          );

                          print('checkout.paymentUrl ${checkout.paymentUrl}');
                          if (success && checkout.paymentUrl != null) {
                            checkout.installOrder();
                            await launchUrl(
                              Uri.parse(checkout.paymentUrl!),
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSilverPackageCard({
    required String id,
    required String title,
    required String title2,
    required String unit,
    required String details,
    required String details1,
    required String details2,
    required String price,
    required String pricePerClass,
    required String discount,
    duration,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          // Text(
                          //   title2,
                          //   style: const TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //     color: AppColors.darkText,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(unit),
                const SizedBox(height: 8),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 12.fSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  details1,
                  style: TextStyle(
                    fontSize: 12.fSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  details2,
                  style: TextStyle(
                    fontSize: 12.fSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${duration}",
                  style: TextStyle(
                    fontSize: 12.fSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  discount == "0"
                      ? SizedBox()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$discount%\nOFF',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: InkWell(
                      onTap: onDelete,
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SvgPicture.asset('assets/svg/dirham.svg'),
                  Text(
                    " $price",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(pricePerClass),
            ],
          ),
        ],
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
