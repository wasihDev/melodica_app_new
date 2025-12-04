import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/receipt_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
import 'package:melodica_app_new/widgets/product_cart.dart';
import 'package:melodica_app_new/widgets/summary_row.dart';

class SignaturePad extends StatelessWidget {
  const SignaturePad({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondaryText.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Draw a Signature Here',
          style: TextStyle(color: AppColors.secondaryText),
        ),
      ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _agreedToTerms = false;
  String? _selectedPackageId; // Package selected in the middle banner

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
          'Checkout',
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
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.h),
                  // --- Product List ---
                  ProductCard(
                    productName: 'Dimension 1 (Piano Classes)',
                    dimensions: 'Dimension 2\nDimension 3',
                    courseDuration: '48 classes - 45 minutes',
                    price: '₫ 1,620',
                    onDelete: () => print('Delete 1'),
                  ),
                  ProductCard(
                    productName: 'Dimension 1 (Piano Classes)',
                    dimensions: 'Dimension 2\nDimension 3',
                    courseDuration: '48 classes - 45 minutes',
                    price: '₫ 1,620',
                    onDelete: () => print('Delete 2'),
                  ),
                  const SizedBox(height: 16),

                  // --- Offer Banner ---
                  const Text(
                    'GET THIS OFFER NOW!',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSilverPackageCard(
                    id: 'checkout_package',
                    title: 'Silver Package',
                    unit: '12 Weeks',
                    details: 'Freezing ------ 1 Week',
                    price: '₫ 1,620',
                    pricePerClass: '150 per Class',
                  ),
                  const SizedBox(height: 24),

                  // --- Apply Code ---
                  const Text(
                    'Apply Code',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '12ASD2s',
                            filled: true,
                            fillColor: AppColors.lightGrey,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => print('Apply code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

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
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.darkText,
                            ),
                            children: [
                              TextSpan(
                                text: 'Privacy Policy.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Terms of Use',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
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
                  const SignaturePad(), // Custom Widget Placeholder
                  const SizedBox(height: 32),

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
                  const SummaryRow(
                    label: 'Course Fee',
                    value: 'AED 9600',
                    valueColor: AppColors.darkText,
                  ),
                  const SummaryRow(
                    label: 'Admission Fee',
                    value: 'AED 150',
                    valueColor: AppColors.darkText,
                  ),
                  const SummaryRow(
                    label: 'Discount',
                    value: '-AED 100',
                    valueColor: AppColors.redError,
                  ), // Assuming red for negative
                  const SummaryRow(
                    label: 'VAT',
                    value: 'AED 150',
                    valueColor: AppColors.darkText,
                  ),
                  const Divider(
                    color: AppColors.lightGrey,
                    thickness: 1,
                    height: 20,
                  ),
                  const SummaryRow(
                    label: 'Total',
                    value: 'AED 9,750',
                    valueColor:
                        AppColors.redError, // Use a contrasting color for Total
                    labelWeight: FontWeight.bold,
                    valueWeight: FontWeight.bold,
                    fontSize: 16,
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
              text: 'Payment',
              onPressed: () {
                // Navigate to Receipt screen upon successful payment
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReceiptScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSilverPackageCard({
    required String id,
    required String title,
    required String unit,
    required String details,
    required String price,
    required String pricePerClass,
  }) {
    bool isSelected = _selectedPackageId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageId = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              const BoxShadow(
                color: AppColors.primary,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '20%\nOFF',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  pricePerClass,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedPackageId,
              onChanged: (value) {
                setState(() {
                  _selectedPackageId = value;
                });
              },
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
