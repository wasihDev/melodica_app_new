import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/whatsapp_link.dart';
import 'package:melodica_app_new/views/dashboard/dashboard_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
import 'package:melodica_app_new/widgets/summary_row.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptScreen extends StatelessWidget {
  ReceiptScreen({super.key});

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildProductDetail(String name, String subtitle, String price) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/dirham.svg',
                  height: 10,
                  width: 10,
                ),
                SizedBox(width: 5),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Uint8List? _signatureBytes;

  @override
  Widget build(BuildContext context) {
    // String formattedDate = DateFormat('dd, MMM yyyy').format(DateTime.now());
    String formattedDate = DateFormat('d MMMM, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () {
            final provider = Provider.of<ServicesProvider>(
              context,
              listen: false,
            );
            final custo = Provider.of<CustomerController>(
              context,
              listen: false,
            );
            provider.clear();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );

            provider.clearList();
            custo.clearStudentForm();
          },
        ),
        title: const Text(
          'Receipt',
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
        child: Consumer<ServicesProvider>(
          builder: (context, ctrl, child) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header ---
                        Text(
                          'Order Number #${ctrl.randomNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        // --- Products ---
                        // _buildSectionTitle('Products'),
                        const Text(
                          'Orders',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.separated(
                          padding: EdgeInsets.zero, // ✅ IMPORTANT
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: ctrl.selectedPackages.length,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildProductDetail(
                              '${ctrl.selectedPackages[index].service}',
                              '${ctrl.selectedPackages[index].sessionstext} -  ${ctrl.selectedPackages[index].service == "Dance Membership" ? "" : ctrl.selectedPackages[index].durationtext}',
                              "${ctrl.selectedPackages[index].price}",
                            );
                          },
                        ),
                        // _buildProductDetail(
                        //   'Dimension 1 (Dance Classes)',
                        //   '₫ 1620',
                        // ),
                        SizedBox(height: 15.h),
                        // --- Enrollment Details ---
                        _buildSectionTitle('Enrollment Details'),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              SummaryRow1(
                                label: 'Student',
                                value: ctrl.isStudentNew == true
                                    ? "${ctrl.customerController.firstNameCtrl.text} ${ctrl.customerController.lastNameCtrl.text}"
                                    : ctrl
                                          .customerController
                                          .selectedStudent!
                                          .fullName,
                                valueColor: AppColors.secondaryText,
                              ),
                              // SummaryRow(
                              //   label: 'Start Date',
                              //   value: formatCreatedOn(
                              //     ctrl
                              //         .customerController
                              //         .selectedStudent!
                              //         .overriddenCreatedOn,
                              //   ),
                              //   valueColor: AppColors.secondaryText,
                              // ),
                              // const SummaryRow(
                              //   label: 'Scheduled Date',
                              //   value: 'Flexible',
                              //   valueColor: AppColors.secondaryText,
                              // ),
                              Consumer<CustomerController>(
                                builder: (context, ctrl, child) {
                                  return SummaryRow1(
                                    label: 'Branch',
                                    value: '${ctrl.selectedBranch}',
                                    valueColor: AppColors.secondaryText,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        //  SummaryRow(
                        //   label: 'Student Type',
                        //   value: ctrl.customerController.selectedStudent!.fullName,
                        //   valueColor: AppColors.secondaryText,
                        // ),
                        SizedBox(height: 15.h),
                        // --- Payment Summary ---
                        _buildSectionTitle('Payment Summary'),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              SummaryRow(
                                label: 'Course Fee',
                                value: ' ${ctrl.totalPrice}',
                                valueColor: AppColors.darkText,
                              ),
                              ctrl.isStudentNew == true
                                  ? SummaryRow(
                                      label: 'Registration Fees',
                                      value: ' 150',
                                      valueColor: Colors.green,
                                    )
                                  : SizedBox.shrink(),
                              SummaryRow(
                                label: 'Discount',
                                value: ' ${ctrl.totalDiscount}',
                                valueColor: AppColors.redError,
                              ),
                              SummaryRow(
                                label: 'VAT',
                                value: ' ${ctrl.vatAmount}',
                                valueColor: Colors.green,
                              ),
                              SummaryRow(
                                label: 'Total',
                                value: ctrl.isStudentNew == true
                                    ? ' ${ctrl.payableAmount + 150}'
                                    : ' ${ctrl.payableAmount}',
                                valueColor: AppColors.darkText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Container(
                //   width: double.infinity,
                //   margin: EdgeInsets.symmetric(horizontal: 20),
                //   height: 52,
                //   child: OutlinedButton.icon(
                //     onPressed: () {},
                //     icon: const Icon(
                //       Icons.check_circle_outline,
                //       color: Colors.green,
                //     ),
                //     label: const Text(
                //       "Done",
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.w600,
                //         color: Colors.black87,
                //       ),
                //     ),
                //     style: OutlinedButton.styleFrom(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(28),
                //       ),
                //       side: const BorderSide(color: Colors.black),
                //     ),
                //   ),
                // ),
                Consumer<ServicesProvider>(
                  builder: (context, ctrl, _) {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          int totalClasses = 0;
                          ctrl.selectedPackages.map((e) {
                            // print('procdcut ${e.sessionstext}');
                            final text = e.sessionstext; // e.g. "20 Classes"
                            final count =
                                int.tryParse(text.split(' ').first) ?? 0;
                            totalClasses += count;
                          }).toList();
                          // print('Total Classes: $totalClasses');
                          openWhatsApp("${totalClasses} Classes");
                        },
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        label: const Text(
                          "Schedule Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                    );
                  },
                ),

                // --- Fixed Bottom Button ---
                SafeArea(
                  bottom: true,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 10.h,
                      top: 12,
                    ),
                    child: PrimaryButton(
                      text: 'Download PDF',
                      onPressed: () async {
                        final file = await generateStudentPdf(ctrl);

                        // Open / Download / Share
                        await Printing.layoutPdf(
                          onLayout: (format) async => file.readAsBytes(),
                        );
                        // PdfService.generateReceiptPdf(signature: _signatureBytes).then((
                        //   va,
                        // ) {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(builder: (context) => ThankYouScreen()),
                        //   );
                        // });
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => ThankYouScreen()),
                        // );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<File> generateStudentPdf(ServicesProvider provider) async {
    final pdf = pw.Document();

    final Uint8List? signatureBytes = await provider.signratureCtrl
        .toPngBytes();

    final signatureImage = signatureBytes != null
        ? pw.MemoryImage(signatureBytes)
        : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              /// Title
              pw.Text(
                'Student Package Details',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              /// Student Info
              /// TODO:: Student
              pw.Text(
                provider.isStudentNew == true
                    ? "Student Name: ${provider.customerController.firstNameCtrl.text} ${provider.customerController.lastNameCtrl.text}"
                    : 'Student Name: ${provider.customerController.selectedStudent!.fullName}',
                style: pw.TextStyle(fontSize: 14),
              ),

              pw.SizedBox(height: 16),

              /// Packages
              pw.Text(
                'Selected Packages',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Column(
                children: provider.selectedPackages
                    .map(
                      (pkg) => pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(8),
                        margin: const pw.EdgeInsets.only(bottom: 6),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('${pkg.service}'),
                                    pw.Text('${pkg.sessionstext}'),
                                  ],
                                ),
                                pw.Text("${pkg.price}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Course Fee',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "AED ${provider.totalPrice}",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              provider.isStudentNew == true
                  ? pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Admission Fees',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.Row(
                          children: [
                            pw.Text(
                              "AED 150",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    )
                  : pw.SizedBox(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Discount',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "AED ${provider.totalDiscount}",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    provider.isStudentNew == true
                        ? 'AED ${provider.payableAmount + 150}'
                        : "AED ${provider.payableAmount}",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
              //  SummaryRow(
              //                               label: 'Course Fee',
              //                               value: 'AED ${ctrl.totalPrice}',
              //                               valueColor: AppColors.darkText,
              //                             ),
              //                             const SummaryRow(
              //                               label: 'Registration Fees',
              //                               value: 'AED 0',
              //                               valueColor: AppColors.darkText,
              //                             ),
              //                             SummaryRow(
              //                               label: 'Discount',
              //                               value: '-AED ${ctrl.totalDiscount}',
              //                               valueColor: AppColors.redError,
              //                             ),
              //                             SummaryRow(
              //                               label: 'Total',
              //                               value: 'AED ${ctrl.payableAmount}',
              //                               valueColor: AppColors.darkText,
              //                             ),
              pw.SizedBox(height: 30),

              /// Signature
              pw.Text(
                'Signature',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              signatureImage != null
                  ? pw.Container(
                      height: 120,
                      width: 250,
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: pw.Image(signatureImage),
                    )
                  : pw.Text('No signature provided'),

              pw.SizedBox(height: 30),

              pw.Text(
                'Date: ${DateTime.now().toString().split(' ').first}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/student_packages.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
