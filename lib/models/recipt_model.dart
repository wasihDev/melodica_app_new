import 'dart:typed_data';

class ReceiptModel {
  // Order info
  final String orderNumber;
  final DateTime orderDate;

  // Products
  final List<ReceiptProduct> products;

  // Enrollment
  final ReceiptEnrollment enrollment;

  // Payment
  final ReceiptPayment payment;

  // Signature (PNG bytes)
  final Uint8List? signatureBytes;

  ReceiptModel({
    required this.orderNumber,
    required this.orderDate,
    required this.products,
    required this.enrollment,
    required this.payment,
    this.signatureBytes,
  });

  double get totalAmount => payment.total;
}

class ReceiptProduct {
  final String title;
  final double price;

  ReceiptProduct({required this.title, required this.price});
}

class ReceiptEnrollment {
  final String studentName;
  final String studentType;
  final DateTime startDate;
  final String scheduledDate;
  final String branch;

  ReceiptEnrollment({
    required this.studentName,
    required this.studentType,
    required this.startDate,
    required this.scheduledDate,
    required this.branch,
  });
}

class ReceiptPayment {
  final double courseFee;
  final double registrationFee;
  final double discount;

  ReceiptPayment({
    required this.courseFee,
    required this.registrationFee,
    required this.discount,
  });

  double get total => courseFee + registrationFee - discount;
}
