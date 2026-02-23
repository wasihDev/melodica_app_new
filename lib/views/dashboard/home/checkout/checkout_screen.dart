import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/utils/common.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:melodica_app_new/views/dashboard/dashboard_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/signature_pad.dart';
import 'package:melodica_app_new/views/dashboard/home/package_selection_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
import 'package:melodica_app_new/views/profile/packages/packages_screen.dart';
import 'package:melodica_app_new/widgets/summary_row.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CheckoutScreen extends StatefulWidget {
  final bool iscomingFromNewStudent;
  const CheckoutScreen({super.key, required this.iscomingFromNewStudent});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       final pdfBytes = await generateFullReceiptPdf(
        //         context.read<ServicesProvider>(),
        //         widget.iscomingFromNewStudent,
        //       );
        //       await Printing.layoutPdf(
        //         onLayout: (PdfPageFormat format) async => pdfBytes,
        //         name: 'Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
        //       );
        //     },
        //     icon: Icon(Icons.abc),
        //   ),
        // ],
        leading: Consumer2<ServicesProvider, CustomerController>(
          builder: (context, provider, custPro, child) {
            return IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
              onPressed: () {
                Navigator.pop(context);
                // if (widget.iscomingFromNewStudent) {
                //   provider.isStudentNew = false;
                //   custPro.clearStudentForm();

                //   Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(builder: (context) => DashboardScreen()),
                //   );
                // } else {
                //   Navigator.pop(context);
                // }
                // provider.clearList();
              },
            );
          },
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.fSize,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ServicesProvider>(
        builder: (context, provider, child) {
          return contentWIdget(context, provider);
        },
      ),
    );
  }

  Widget contentWIdget(BuildContext context, ServicesProvider provider) {
    final grouped = provider.packagesGroupedByStudent;

    return SafeArea(
      bottom: Platform.isIOS ? false : true,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.adaptSize),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // list view that has students names
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: grouped.entries.map((entry) {
                      final student = entry.key;
                      final packages = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Student Header
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Text(
                              widget.iscomingFromNewStudent
                                  ? provider
                                        .customerController
                                        .firstNameCtrl
                                        .text
                                        .toString()
                                  : student,
                              style: TextStyle(
                                fontSize: 14.fSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          // Packages for this student
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: packages.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = packages[index];
                              final pkg = item.package;
                              final double discountedPrice =
                                  double.tryParse(pkg.discount.toString()) ??
                                  0.0;
                              final double discountedAmount =
                                  pkg.price * (discountedPrice / 100);
                              String perClassCost;
                              if (provider.tab == "Dance") {
                                perClassCost = (pkg.price / pkg.sessions)
                                    .toStringAsFixed(0);
                              } else {
                                perClassCost =
                                    ((pkg.price - discountedAmount) /
                                            pkg.sessions)
                                        .toStringAsFixed(2);
                              }
                              return _buildSilverPackageCard(
                                id: 'provider_package',
                                title: pkg.serviceName,
                                title2: '',
                                studentName: "",
                                unit: pkg.sessionsText,
                                duration: provider.tab == "Dance"
                                    ? ""
                                    : "Duration: ${pkg.duration} min",
                                details: 'Freezing Weeks: ${pkg.freezings}',
                                price: pkg.price.toString().split('.').first,
                                pricePerClass: "$perClassCost per class",
                                discount: '${pkg.discount}',
                                onDelete: () {
                                  final globalIndex = provider.selectedPackages
                                      .indexOf(item);
                                  provider.removePackageAt(globalIndex);
                                },
                                details1:
                                    'Class Cancellations: ${pkg.cancellations}',
                                details2: pkg.frequencyText.isNotEmpty
                                    ? 'Classes: ${formatFrequency(pkg.frequencyText)}'
                                    : '',
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                  /// OLd listview
                  // ListView.separated(
                  //   physics: NeverScrollableScrollPhysics(),
                  //   itemCount: provider.selectedPackages.length,
                  //   shrinkWrap: true,
                  //   padding: EdgeInsets.all(0),
                  //   separatorBuilder: (context, index) => SizedBox(height: 10),
                  //   itemBuilder: (context, index) {
                  //     final item = provider.selectedPackages[index];
                  //     final pkg = item.package;
                  //     final student = item.student;
                  //     final double discountedPrice =
                  //         double.tryParse(pkg.discount.toString()) ?? 0.0;
                  //     final double sessions = provider
                  //         .selectedPackages[index]
                  //         .package
                  //         .sessions
                  //         .toDouble();
                  //     final discountedAmount =
                  //         pkg.price * (discountedPrice / 100);
                  //     String perClassCost;
                  //     if (provider.tab == "Dance") {
                  //       perClassCost =
                  //           (pkg.price /
                  //                   provider
                  //                       .selectedPackages[index]
                  //                       .package
                  //                       .sessions)
                  //               .toStringAsFixed(0);
                  //     } else {
                  //       perClassCost =
                  //           ((pkg.price - discountedAmount) / sessions)
                  //               .toStringAsFixed(2);
                  //     }
                  //     return _buildSilverPackageCard(
                  //       id: 'provider_package',
                  //       title: pkg.serviceName,
                  //       title2: '',
                  //       studentName: student.firstName,
                  //       unit: pkg.sessionsText,
                  //       duration: provider.tab == "Dance"
                  //           ? ""
                  //           : "Duration: ${pkg.duration} min",
                  //       details:
                  //           'Freezing Weeks: ${pkg.freezings == null ? 0 : pkg.freezings}',
                  //       price: '${pkg.price.toString().split('.').first}',
                  //       pricePerClass:
                  //           "$perClassCost per class", // '${(provider.selectedPackages[index].price / provider.selectedPackages[index].sessions).toStringAsFixed(0)} per Class',
                  //       discount: '${pkg.discount}',
                  //       onDelete: () => provider.removePackageAt(index),
                  //       details1: 'Class Cancellations: ${pkg.cancellations}',
                  //       details2:
                  //           pkg.frequencyText != null &&
                  //               pkg.frequencyText!.isNotEmpty
                  //           ? 'Classes: ${formatFrequency(pkg.frequencyText)}'
                  //           : '',
                  //     );
                  //   },
                  // ),
                  SizedBox(height: 5.h),
                  widget.iscomingFromNewStudent
                      ? SizedBox()
                      : Consumer<ServicesProvider>(
                          builder: (context, pro, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  pro.removeSelectpackageSelection();
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PackageSelectionScreen(
                                          isShowdanceTab: false,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white,

                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "+ Add Package for Another Student",
                                  style: TextStyle(
                                    fontSize: 14.fSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors
                                        .darkText, // Text color is dark on yellow
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  SizedBox(height: 10),
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
                            style: TextStyle(
                              fontSize: 12.fSize,
                              color: AppColors.darkText,
                            ),
                            children: [
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 14.fSize,
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
                                  fontSize: 14.fSize,
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
                  SizedBox(height: 16.h),
                  Text(
                    'Draw a Signature',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.fSize,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SignaturePad(
                    onSave: (bytes) {
                      provider.signatureBytes = bytes;
                      debugPrint('Auto-saved: ${bytes?.length}');
                    },
                  ),
                  SizedBox(height: 5.h),

                  // --- Payment Summary ---
                  Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.fSize,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      children: [
                        SummaryRow(
                          label: 'Course Fee',
                          value: '${provider.totalPrice.toStringAsFixed(2)}',
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
                          value: '${provider.totalDiscount.toStringAsFixed(2)}',
                          valueColor: AppColors.redError,
                        ), // Assuming red for negative
                        SummaryRow(
                          label: 'VAT',
                          value: '${provider.vatAmount.toStringAsFixed(2)}',
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
                  ),
                ],
              ),

              // --- Fixed Bottom Button ---
              SafeArea(
                bottom: Platform.isIOS ? false : true,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0, right: 0, top: 12),
                  child: PrimaryButton(
                    text: provider.loading == true
                        ? "Please wait..."
                        : 'Payment',
                    onPressed: () async {
                      if (provider.signatureBytes == null) {
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

                      provider.setPaymentType(PaymentType.packagesOrder);

                      final success = await provider.startCheckout(
                        context,
                        amount: widget.iscomingFromNewStudent == true
                            ? provider.payableAmount + 150
                            : provider
                                  .customerController
                                  .selectedStudent!
                                  .isregistred
                                  .contains('Yes')
                            ? provider.payableAmount
                            : provider.payableAmount + 150,
                      );
                      final pdfBytes = await generateFullReceiptPdf(
                        provider,
                        widget.iscomingFromNewStudent,
                      );
                      String base64Image = base64Encode(pdfBytes);
                      if (success && provider.paymentUrl != null) {
                        provider.installOrder(
                          checkOutScreenBase64: '$base64Image',
                        );
                        provider.removeSelectpackageSelection();
                        await launchUrl(
                          Uri.parse(provider.paymentUrl!),
                          mode: LaunchMode.externalApplication,
                        );
                      }
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
    required String studentName,
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
                            style: TextStyle(
                              fontSize: 16.fSize,
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
                            '${discount.split('.').first}%\nOFF',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.fSize,
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
                  SvgPicture.asset(
                    'assets/svg/dirham.svg',
                    height: 14.h,
                    width: 14.w,
                  ),
                  Text(
                    " $price",
                    style: TextStyle(
                      fontSize: 20.fSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(pricePerClass, style: TextStyle(fontSize: 16.fSize)),
              // Text(
              //   "Student: $studentName",
              //   style: TextStyle(
              //     fontSize: 12.fSize,
              //     fontWeight: FontWeight.w600,
              //     color: AppColors.redError,
              //   ),
              // ),
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

  //// PDF CONTENT WIDGET
  Future<Uint8List> generateFullReceiptPdf(
    ServicesProvider provider,
    bool isNewStudent,
  ) async {
    final svgRaw = await rootBundle.loadString('assets/svg/dirham_logo.svg');
    final pdf = pw.Document();
    final iconBytes = await rootBundle.load('assets/images/check.png');
    final iconImage = pw.MemoryImage(iconBytes.buffer.asUint8List());

    // Load signature if it exists
    pw.MemoryImage? signatureImage;
    if (provider.signatureBytes != null) {
      signatureImage = pw.MemoryImage(provider.signatureBytes!);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "CHECKOUT RECEIPT",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(DateTime.now().toString().split(' ').first),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Customer Name: ${provider.customerController.customer!.fullName}',
            ),
            pw.Text(
              'Customer Email: ${provider.customerController.customer!.email}',
            ),
            pw.SizedBox(height: 10),
            // 1. LISTVIEW CONTENT (The Packages)
            ...provider.selectedPackages.map((item) {
              // Logic mirrored from your itemBuilder
              final pkg = item.package;
              final student = item.student;

              final double discountedPrice =
                  double.tryParse(pkg.discount.toString()) ?? 0.0;
              // final double sessions = pkg.sessions.toDouble();
              final discountedAmount = pkg.price * (discountedPrice / 100);

              // String perClassCost;
              // if (provider.tab == "Dance") {
              //   perClassCost = (pkg.price / pkg.sessions).toStringAsFixed(0);
              // } else {
              //   perClassCost = ((pkg.price - discountedAmount) / sessions)
              //       .toStringAsFixed(2);
              // }
              final num originalPrice = pkg.price;
              final num discountPercentage =
                  num.tryParse(pkg.discount.toString()) ?? 0.0;
              final num discountAmount =
                  originalPrice * (discountPercentage / 100);
              final num finalItemPrice =
                  originalPrice - discountAmount; // The price after discount

              // Calculate per class cost based on the final price
              final num sessions = pkg.sessions.toDouble();
              String perClassCost;
              if (provider.tab == "Dance") {
                perClassCost = (finalItemPrice / sessions).toStringAsFixed(0);
              } else {
                perClassCost = (finalItemPrice / sessions).toStringAsFixed(2);
              }
              final bool chargeAdmission =
                  provider.isStudentNew == true || student.isregistred != 'Yes';

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            pkg.serviceName,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.Text(
                            pkg.sessionsText,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "Freezing Weeks: ${pkg.freezings ?? 0}",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            "Class Cancellations: ${pkg.cancellations}",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          if (pkg.frequencyText != null &&
                              pkg.frequencyText!.isNotEmpty)
                            pw.Text(
                              "Classes: ${pkg.frequencyText}",
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          if (provider.tab != "Dance")
                            pw.Text(
                              "Duration: ${pkg.duration} min",
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Student Name:  ${chargeAdmission
                                    ? "${provider.customerController.firstNameCtrl.text}"
                                    : student.isregistred == 'Yes'
                                    ? student.fullName
                                    : student.fullName}',
                              ),
                              pw.Text(
                                'Student Email: ${chargeAdmission
                                    ? "${provider.customerController.emailCtrl.text}"
                                    : student.isregistred == 'Yes'
                                    ? student.email
                                    : student.email}}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // pw.Column(
                    //   crossAxisAlignment: pw.CrossAxisAlignment.end,
                    //   children: [
                    // if (pkg.discount != "0")
                    //   pw.Container(
                    //     padding: const pw.EdgeInsets.all(4),
                    //     color: PdfColors.orange,
                    //     child: pw.Text(
                    //       "${pkg.discount}% OFF",
                    //       style: pw.TextStyle(
                    //         color: PdfColors.white,
                    //         fontSize: 8,
                    //         fontWeight: pw.FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    //     pw.SizedBox(height: 5),
                    //     pw.Text(
                    //       "AED ${pkg.price.toString().split('.').first}",
                    //       style: pw.TextStyle(
                    //         fontSize: 16,
                    //         fontWeight: pw.FontWeight.bold,
                    //       ),
                    //     ),
                    //     pw.Text(
                    //       "$perClassCost per class",
                    //       style: const pw.TextStyle(fontSize: 9),
                    //     ),
                    //   ],
                    // ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        if (pkg.discount != "0")
                          pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            color: PdfColors.orange,
                            child: pw.Text(
                              "${pkg.discount}% OFF",
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        if (discountPercentage > 0) ...[
                          // Show original price with a strikethrough effect (manual)
                          pw.Row(
                            children: [
                              pw.SvgImage(
                                svg: svgRaw,
                                width: 7,
                                height: 7,
                                colorFilter: PdfColors.grey600,
                              ),
                              pw.Text(
                                " ${originalPrice.toStringAsFixed(2)}",
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey600,
                                  decoration: pw.TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.Text(
                                'Saved: ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.green,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SvgImage(
                                svg: svgRaw,
                                width: 7,
                                height: 7,
                                colorFilter: PdfColors.green,
                              ),
                              pw.Text(
                                " ${discountAmount.toStringAsFixed(2)}",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.green,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // THE PRICE AFTER DISCOUNT
                        pw.Row(
                          children: [
                            pw.SvgImage(svg: svgRaw, width: 13, height: 13),
                            pw.Text(
                              " ${finalItemPrice.toStringAsFixed(2)}",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            pw.SizedBox(height: 10),
            // --- 3. TERMS & SIGNATURE SECTION ---
            // pw.Expanded(
            //   flex: 2,
            //   child: pw.Column(
            //     crossAxisAlignment: pw.CrossAxisAlignment.start,
            //     children: [
            //       pw.Checkbox(
            //         value: true,
            //         name: 'I agree to the Terms and Conditions',
            //         activeColor: PdfColors.orange,
            //       ),
            //     ],
            //   ),
            // ),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "TERMS & CONDITIONS",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),

                      pw.SizedBox(height: 10),

                      pw.Row(
                        children: [
                          pw.Container(
                            width: 12,
                            height: 12,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: PdfColors.black,
                                width: 1,
                              ),
                              color: PdfColors.white,
                            ),
                            child: pw.Image(iconImage, width: 12, height: 12),
                          ),
                          pw.Text(
                            " I agree to the Privacy Policy & Terms of Use",
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // 2. PAYMENT SUMMARY
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  _buildPdfSummaryRow(
                    "Course Fee",
                    provider.totalPrice.toStringAsFixed(2),
                    svgRaw: svgRaw,
                  ),
                  _buildPdfSummaryRow(
                    "Admission Fee",
                    (isNewStudent ||
                            provider
                                    .customerController
                                    .selectedStudent!
                                    .isregistred !=
                                'Yes')
                        ? "150.00"
                        : "0.00",
                    svgRaw: svgRaw,
                  ),
                  _buildPdfSummaryRow(
                    "Discount",
                    "-${provider.totalDiscount.toStringAsFixed(2)}",
                    color: PdfColors.red,
                    svgRaw: svgRaw,
                  ),
                  _buildPdfSummaryRow(
                    "VAT",
                    provider.vatAmount.toStringAsFixed(2),
                    svgRaw: svgRaw,
                  ),
                  pw.Divider(color: PdfColors.grey),
                  _buildPdfSummaryRow(
                    "Total",
                    widget.iscomingFromNewStudent == true
                        ? "${(provider.payableAmount + 150).toStringAsFixed(2)}"
                        : '${provider.customerController.selectedStudent!.isregistred == 'Yes' ? provider.payableAmount : "${(provider.payableAmount + 150).toStringAsFixed(2)}"}',
                    //  provider.payableAmount.toStringAsFixed(2),
                    isBold: true,
                    fontSize: 14,
                    svgRaw: svgRaw,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // 3. SIGNATURE SECTION
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Signature",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                if (signatureImage != null)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                        height: 80,
                        width: 160,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                        child: pw.Image(signatureImage),
                      ),
                    ],
                  )
                else
                  pw.Text(
                    "No signature provided",
                    style: pw.TextStyle(color: PdfColors.grey, fontSize: 10),
                  ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 10,
    PdfColor? color,
    required String svgRaw,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Row(
            children: [
              pw.SvgImage(
                svg: svgRaw,
                width: isBold ? 13 : 10,
                height: isBold ? 13 : 10,
                colorFilter: color,
              ),
              pw.SizedBox(width: 2),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
