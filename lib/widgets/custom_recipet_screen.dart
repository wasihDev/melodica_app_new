import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/profile/packages/widget/packages_dialog_service.dart';
import 'package:provider/provider.dart';

class CustomRecipetScreen extends StatefulWidget {
  final String orderId;
  final String amount;
  final String paymentMethod;
  final String status;
  final bool isSchedule;
  final DateTime date;

  const CustomRecipetScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
    required this.isSchedule,
  });

  @override
  State<CustomRecipetScreen> createState() => _CustomRecipetScreenState();
}

class _CustomRecipetScreenState extends State<CustomRecipetScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isSchedule) return;

      final packageProvider = context.read<PackageProvider>();
      final scheduleProvider = context.read<ScheduleProvider>();

      // Safety check
      if (packageProvider.endDate == null ||
          packageProvider.selectedPackage == null)
        return;

      final nextClassDate = scheduleProvider.getNextClassAfterEndDate(
        endDate: packageProvider.endDate!,
        subject: packageProvider.selectedPackage!.subject,
      );

      if (nextClassDate == null) {
        PopupService.showNoUpcomingClassesPopup(
          context,
          packageProvider.endDate,
          packageProvider.startDate,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double incomingValue = double.tryParse(widget.amount) ?? 0.0;

    final double totalAmount;
    final double baseAmount;
    final double vat;

    if (widget.isSchedule) {
      totalAmount = incomingValue;
      baseAmount = totalAmount / 1.05;
      vat = totalAmount - baseAmount;
    } else {
      baseAmount = incomingValue;
      vat = baseAmount * 0.05;
      totalAmount = baseAmount + vat;
    }

    final isSuccess = widget.status.toLowerCase() == 'success';
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50, // Soft background color
        appBar: AppBar(
          title: const Text('Payment Receipt'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.adaptSize),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ✅ Status Section
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: (isSuccess ? Colors.green : Colors.red)
                            .withOpacity(0.1),
                        child: Icon(
                          isSuccess
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                          color: isSuccess ? Colors.green : Colors.red,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSuccess ? 'Payment Successful' : 'Payment Failed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSuccess
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Total:  ",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/svg/dirham.svg',
                            color: Colors.black,
                            height: 16.h,
                            width: 16.w,
                          ),
                          Text(
                            " ${totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(
                          thickness: 1,
                          height: 1,
                        ), // Optional: Replace with Dashed Divider
                      ),

                      // ✅ Payment Details
                      _buildInfoRow(
                        true,
                        'Order ID',
                        widget.orderId,
                        isShort: true,
                      ),
                      _buildInfoRow(
                        false,
                        'Payment Method',
                        widget.paymentMethod,
                      ),
                      _buildInfoRow(
                        false,
                        'Date',
                        '${widget.date.day}/${widget.date.month}/${widget.date.year} ${widget.date.hour}:${widget.date.minute.toString().padLeft(2, '0')}',
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(thickness: 1, height: 1),
                      ),

                      // ✅ Pricing Breakdown
                      _buildPriceRow(
                        true,
                        'Base Amount',
                        baseAmount.toStringAsFixed(2),
                      ),
                      _buildPriceRow(true, 'VAT (5%)', vat.toStringAsFixed(2)),
                      const SizedBox(height: 12),
                      _buildPriceRow(
                        false,
                        'Total Amount',
                        totalAmount.toStringAsFixed(2),
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ✅ Done Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.adaptSize),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
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
                    },
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    bool isoderID,

    String title,
    String value, {
    bool isShort = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12.fSize, color: Colors.grey.shade600),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: isShort ? TextOverflow.ellipsis : null,
              style: TextStyle(
                fontSize: isoderID == true ? 10.fSize : 12.fSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    bool isIcon,
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Row(
            children: [
              if (isTotal)
                SvgPicture.asset(
                  'assets/svg/dirham.svg',
                  color: Colors.black,
                  height: 11.h,
                  width: 11.w,
                ),
              if (isIcon)
                SvgPicture.asset(
                  'assets/svg/dirham.svg',
                  color: Colors.black,
                  height: 11.h,
                  width: 11.w,
                ),
              Text(
                " $value",
                style: TextStyle(
                  fontSize: isTotal ? 18 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  color: isTotal ? Colors.black : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///////////
