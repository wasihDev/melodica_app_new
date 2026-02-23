import 'dart:convert';

import 'package:intl/intl.dart';

List<GetCancellationModel> GetCancellationModelFromJson(String str) =>
    List<GetCancellationModel>.from(
      json.decode(str).map((x) => GetCancellationModel.fromJson(x)),
    );

class GetCancellationModel {
  final String id;
  final String studentName;
  final String location;
  final String className;
  final String classDate; // Kept as String for raw display
  final String classTime;
  final String newClassTime;
  final String preferredTiming;
  final String reason;
  final String requestedBy;
  final String clientId;
  final String package;
  final String rebookStatus;
  final String catStatus;
  final String remarks;
  final String paymentReference;
  final String processedBy;
  final String rejectionReason;
  final String requestDate;
  final String lastUpdate;

  GetCancellationModel({
    required this.id,
    required this.studentName,
    required this.location,
    required this.className,
    required this.classDate,
    required this.classTime,
    required this.newClassTime,
    required this.preferredTiming,
    required this.reason,
    required this.requestedBy,
    required this.clientId,
    required this.package,
    required this.rebookStatus,
    required this.catStatus,
    required this.remarks,
    required this.paymentReference,
    required this.processedBy,
    required this.rejectionReason,
    required this.requestDate,
    required this.lastUpdate,
  });

  factory GetCancellationModel.fromJson(Map<String, dynamic> json) =>
      GetCancellationModel(
        id: json["id"] ?? "",
        studentName: json["student_name"] ?? "",
        location: json["location"] ?? "",
        className: json["class"] ?? "",
        classDate: json["class_date"] ?? "",
        classTime: json["class_time"] ?? "",
        newClassTime: json["new_class_time"] ?? "",
        preferredTiming: json["preferred_timing"] ?? "",
        reason: json["reason"] ?? "",
        requestedBy: json["requested_by"] ?? "",
        clientId: json["client_id"] ?? "",
        package: json["package"] ?? "",
        rebookStatus: json["rebook_status"] ?? "",
        catStatus: json["cat_status"] ?? "",
        remarks: json["remarks"] ?? "",
        paymentReference: json["payment_reference"] ?? "",
        processedBy: json["processed_by"] ?? "",
        rejectionReason: json["rejection_reason"] ?? "",
        requestDate: json["request_date"] ?? "",
        lastUpdate: json["last_update"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "student_name": studentName,
    "location": location,
    "class": className,
    "class_date": classDate,
    "class_time": classTime,
    "new_class_time": newClassTime,
    "preferred_timing": preferredTiming,
    "reason": reason,
    "requested_by": requestedBy,
    "client_id": clientId,
    "package": package,
    "rebook_status": rebookStatus,
    "cat_status": catStatus,
    "remarks": remarks,
    "payment_reference": paymentReference,
    "processed_by": processedBy,
    "rejection_reason": rejectionReason,
    "request_date": requestDate,
    "last_update": lastUpdate,
  };

  /// Parse original class datetime
  DateTime? get classDateTime {
    try {
      if (classDate.isEmpty || classTime.isEmpty) return null;
      return DateFormat('dd/MM/yyyy hh:mm a').parse('$classDate $classTime');
    } catch (_) {
      return null;
    }
  }

  /// Parse new (rescheduled) datetime
  DateTime? get newClassDateTime {
    try {
      if (newClassTime.isEmpty) return null;
      return DateFormat('dd/MM/yyyy hh:mm a').parse(newClassTime);
    } catch (_) {
      return null;
    }
  }
  //   DateTime? get newClassDateTimeOnly {
  //   try {
  //     if (newClassTime.isEmpty) return null;
  //     return DateFormat('dd/MM/yyyy hh:mm a').parse(newClassTime);
  //   } catch (_) {
  //     return null;
  //   }
  // }

  /// ✅ "Feb"
  String get monthShort {
    final dt = classDateTime;
    if (dt == null) return '--';
    return DateFormat('MMM').format(dt);
  }

  /// ✅ "19"
  String get day {
    final dt = classDateTime;
    if (dt == null) return '--';
    return DateFormat('d').format(dt);
  }

  /// ✅ "Thu"
  String get dayOfWeek {
    final dt = classDateTime;
    if (dt == null) return '--';
    return DateFormat('EEE').format(dt);
  }

  /// ✅ "04:45 PM"
  String get time {
    final dt = classDateTime;
    if (dt == null) return '--';
    return DateFormat('h:mm a').format(dt);
  }

  /// ✅ "04:45 PM → 07:15 PM" (if rescheduled)
  String get timeWithReschedule {
    final original = classDateTime;
    final updated = newClassDateTime;

    if (original == null) return '--';

    final originalTime = DateFormat('h:mm a').format(original);

    if (updated == null) return originalTime;

    final newTime = DateFormat('h:mm a').format(updated);
    return '$originalTime - $newTime';
  }

  String get classTimeParse {
    final original = classTime;

    final newclassTime = DateFormat('hh:mm a').parse(original);
    final newTime = DateFormat('h:mm a').format(newclassTime);
    return '$newTime';
  }
}
