// import 'package:flutter/material.dart';
// import 'package:melodica_app_new/constants/app_colors.dart';
// import 'package:melodica_app_new/providers/schedule_provider.dart';
// import 'package:melodica_app_new/providers/services_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class CheckoutScreenFreeze extends StatelessWidget {
//   const CheckoutScreenFreeze({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Payment",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSectionTitle("Order Summary"),
//                   const SizedBox(height: 12),
//                   _buildSummaryCard(),
//                   const SizedBox(height: 30),
//                   _buildSectionTitle("Payment Method"),
//                   const SizedBox(height: 12),
//                   _buildNetworkInternationalOption(),
//                 ],
//               ),
//             ),
//           ),
//           _buildBottomAction(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//         color: Colors.black87,
//       ),
//     );
//   }

//   Widget _buildSummaryCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildSummaryRow("Service", "Package Extension"),
//           const Divider(height: 30),
//           _buildSummaryRow("Price", "50.00 AED"),
//           _buildSummaryRow("VAT ", "0.0 AED"),
//           const Divider(height: 30),
//           _buildSummaryRow("Total Amount", "50.00 AED", isTotal: true),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: isTotal ? Colors.black : Colors.grey[600],
//               fontSize: isTotal ? 18 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: isTotal ? const Color(0xFFFF6D00) : Colors.black,
//               fontSize: isTotal ? 20 : 15,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNetworkInternationalOption() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFFF6D00), width: 1.5),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.security, color: Colors.blue, size: 28),
//           const SizedBox(width: 15),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Network International",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "Secure Payment Gateway",
//                   style: TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.check_circle, color: Color(0xFFFF6D00)),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomAction(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: SafeArea(
//         child: SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: Consumer<ScheduleProvider>(
//             builder: (context, checkout, child) {
//               return ElevatedButton(
//                 onPressed: () async {
//                   final success = await checkout.servicesProvider.startCheckout(
//                     context,
//                     amount: 50,
//                     redirectUrl: "https://melodica-mobile.web.app",
//                   );

//                   if (success && checkout.paymentUrl != null) {
//                     await launchUrl(
//                       Uri.parse(checkout.paymentUrl!),
//                       mode: LaunchMode.externalApplication,
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   "Pay Now",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
