import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
import 'package:melodica_app_new/widgets/summary_row.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
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

  Widget _buildProductDetail(String name, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          ),
          Text(
            price,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () {
            Navigator.pop(context);
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
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/svg/exit.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              // Handle forward action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  const Text(
                    'Order Number #00001',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '24, Nov 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),

                  // --- Products ---
                  _buildSectionTitle('Products'),
                  const Text(
                    'Products we buy',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildProductDetail('Dimension 1 (Piano Classes)', '₫ 1620'),
                  _buildProductDetail('Dimension 1 (Dance Classes)', '₫ 1620'),

                  // --- Enrollment Details ---
                  _buildSectionTitle('Enrollment Details'),
                  const SummaryRow(
                    label: 'Student',
                    value: 'Maxben',
                    valueColor: AppColors.secondaryText,
                  ),
                  const SummaryRow(
                    label: 'Student Type',
                    value: 'New',
                    valueColor: AppColors.secondaryText,
                  ),
                  const SummaryRow(
                    label: 'Start Date',
                    value: '24 Nov 2025',
                    valueColor: AppColors.secondaryText,
                  ),
                  const SummaryRow(
                    label: 'Scheduled Date',
                    value: 'Flexible',
                    valueColor: AppColors.secondaryText,
                  ),
                  const SummaryRow(
                    label: 'Branch',
                    value: 'Dubai',
                    valueColor: AppColors.secondaryText,
                  ),

                  // --- Payment Summary ---
                  _buildSectionTitle('Payment Summary'),
                  const SummaryRow(
                    label: 'Course Fee',
                    value: 'AED 9600',
                    valueColor: AppColors.darkText,
                  ),
                  const SummaryRow(
                    label: 'Registration Fees',
                    value: 'AED 150',
                    valueColor: AppColors.darkText,
                  ),
                  const SummaryRow(
                    label: 'Discount',
                    value: '-AED 100',
                    valueColor: AppColors.redError,
                  ),
                  const SummaryRow(
                    label: 'Total',
                    value: 'AED 9,750',
                    valueColor: AppColors.darkText,
                  ),
                ],
              ),
            ),
          ),
          // --- Fixed Bottom Button ---
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 24,
              top: 12,
            ),
            child: PrimaryButton(
              text: 'Download PDF',
              onPressed: () {
                print('Download PDF button pressed!');
              },
            ),
          ),
        ],
      ),
    );
  }
}
