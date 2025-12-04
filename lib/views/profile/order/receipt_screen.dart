import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/widgets/custom_appbar.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Receipt'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Divider(),
            // Order header
            const SizedBox(height: 8),
            const Text(
              'Order Number #00001',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text('24, Nov 2025', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            // Scrollable content
            Expanded(
              child: ListView(
                children: [
                  _sectionTitle('Products', 'Products we buy'),
                  const SizedBox(height: 8),
                  CardContainer(
                    child: Column(
                      children: const [
                        ProductRow(
                          title: 'Dimension 1 (piano Classes)',
                          amount: 'AED 1620',
                        ),
                        Divider(height: 1),
                        ProductRow(
                          title: 'Dimension 1 (Dance Classes)',
                          amount: 'AED 1620',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _sectionTitle('Enrollment Details', ''),
                  const SizedBox(height: 8),
                  CardContainer(
                    child: Column(
                      children: const [
                        DetailRow(label: 'Student', value: 'Maxben'),
                        Divider(height: 1),
                        DetailRow(label: 'Student Type', value: 'New'),
                        Divider(height: 1),
                        DetailRow(label: 'Start Date', value: '24 Nov 2025'),
                        Divider(height: 1),
                        DetailRow(label: 'Scheduled Date', value: 'Flexible'),
                        Divider(height: 1),
                        DetailRow(label: 'Branch', value: 'Dubai'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _sectionTitle('Payment Summary', ''),
                  const SizedBox(height: 8),
                  CardContainer(
                    child: Column(
                      children: [
                        const DetailRow(label: 'Course Fee', value: 'AED 9600'),
                        const Divider(height: 1),
                        const DetailRow(
                          label: 'Registration Fees',
                          value: 'AED 150',
                        ),
                        const Divider(height: 1),
                        // Discount as red negative
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Discount',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '-AED 100',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'AED 9,750',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        if (subtitle.isNotEmpty) const SizedBox(height: 4),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

/// small row used in products list
class ProductRow extends StatelessWidget {
  final String title;
  final String amount;
  const ProductRow({super.key, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// label / value rows used across panels
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

/// common rounded white container used in the receipt panels
class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightGrey,
      shape: RoundedRectangleBorder(
        // side: const BorderSide(color: outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
