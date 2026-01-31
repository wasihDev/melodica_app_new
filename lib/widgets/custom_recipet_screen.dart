import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:provider/provider.dart';

class CustomRecipetScreen extends StatelessWidget {
  final String orderId;
  final String amount;
  final String paymentMethod;
  final String status;
  final DateTime date;
  // final Package package;
  const CustomRecipetScreen({
    super.key,
    required this.orderId,
    // required this.package,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final double baseAmount = double.parse(amount);
    final double vat = baseAmount * 0.05;
    final double total = baseAmount + vat;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Receipt'),
          centerTitle: true,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ✅ Success Icon
              Icon(
                status.toLowerCase() == 'success'
                    ? Icons.check_circle
                    : Icons.error,
                color: status.toLowerCase() == 'success'
                    ? Colors.green
                    : Colors.red,
                size: 90,
              ),

              const SizedBox(height: 12),

              Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: status.toLowerCase() == 'success'
                      ? Colors.green
                      : Colors.red,
                ),
              ),

              const SizedBox(height: 24),

              _buildRow('Order ID', orderId),
              _buildRow('Vat', "AED ${vat}"),
              _buildRow('Amount', "AED ${total}"),
              _buildRow('Payment Method', paymentMethod),
              _buildRow(
                'Date',
                '${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
              ),

              const Spacer(),

              // ✅ Done Button
              SafeArea(
                bottom: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          AppColors.primary,
                        ),
                      ),
                      onPressed: () async {
                        final provider = Provider.of<PackageProvider>(
                          context,
                          listen: false,
                        );
                        provider.selectedPackage = null;
                        provider.selectedReason = '';
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.dashboard,
                        );
                        // await provider
                        //     .callFreezingApi(context, '', package, ref: orderId)
                        //     .then((val) {

                        //     });
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
