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
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
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
        actions: [
          // IconButton(
          //   onPressed: () async {
          //     final pdfBytes = await generateFullReceiptPdf(
          //       context.read<ServicesProvider>(),
          //       widget.iscomingFromNewStudent,
          //     );
          //     await Printing.layoutPdf(
          //       onLayout: (PdfPageFormat format) async => pdfBytes,
          //       name: 'Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
          //     );
          //   },
          //   icon: Icon(Icons.abc),
          // ),
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
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
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
      body: Consumer<ServicesProvider>(
        builder: (context, provider, child) {
          return contentWIdget(context, provider);
        },
      ),
    );
  }

  Widget contentWIdget(BuildContext context, ServicesProvider provider) {
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
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: provider.selectedPackages.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => SizedBox(height: 10),
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
                                    provider.selectedPackages[index].sessions)
                                .toStringAsFixed(0);
                      } else {
                        perClassCost =
                            ((provider.selectedPackages[index].price -
                                        discountedAmount) /
                                    sessions)
                                .toStringAsFixed(2);
                      }
                      return _buildSilverPackageCard(
                        id: 'provider_package',
                        title: provider.selectedPackages[index].service,
                        title2: '',
                        unit: provider.selectedPackages[index].sessionstext,
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
                            provider.selectedPackages[index].frequencytext !=
                                    null &&
                                provider
                                    .selectedPackages[index]
                                    .frequencytext!
                                    .isNotEmpty
                            ? 'Classes: ${formatFrequency(provider.selectedPackages[index].frequencytext)}'
                            : '',
                      );
                    },
                  ),

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
                  SignaturePad(
                    onSave: (bytes) {
                      provider.signatureBytes = bytes;
                      debugPrint('Auto-saved: ${bytes?.length}');
                    },
                  ),
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

  //// PDF CONTENT WIDGET
  Future<Uint8List> generateFullReceiptPdf(
    ServicesProvider provider,
    bool isNewStudent,
  ) async {
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
            ...provider.selectedPackages.map((pkg) {
              // Logic mirrored from your itemBuilder
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
                  provider.isStudentNew == true ||
                  provider.customerController.selectedStudent?.isregistred !=
                      'Yes';
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
                            pkg.service,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.Text(
                            pkg.sessionstext,
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
                          if (pkg.frequencytext != null &&
                              pkg.frequencytext!.isNotEmpty)
                            pw.Text(
                              "Classes: ${pkg.frequencytext}",
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
                                'Student Name:  ${chargeAdmission ? "${provider.customerController.firstNameCtrl.text}" : provider.customerController.selectedStudent?.fullName}',
                              ),
                              pw.Text(
                                'Student Email: ${chargeAdmission ? "${provider.customerController.emailCtrl.text}" : provider.customerController.selectedStudent?.email}',
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
                          pw.Text(
                            "AED ${originalPrice.toStringAsFixed(2)}",
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey600,
                              decoration: pw.TextDecoration.lineThrough,
                            ),
                          ),
                          pw.Text(
                            "Saved: AED ${discountAmount.toStringAsFixed(2)}",
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.green,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                        // THE PRICE AFTER DISCOUNT
                        pw.Text(
                          "AED ${finalItemPrice.toStringAsFixed(2)}",
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
                  ),
                  _buildPdfSummaryRow(
                    "Discount",
                    "-${provider.totalDiscount.toStringAsFixed(2)}",
                    color: PdfColors.red,
                  ),
                  _buildPdfSummaryRow(
                    "VAT",
                    provider.vatAmount.toStringAsFixed(2),
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
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
