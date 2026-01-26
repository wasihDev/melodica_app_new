import 'package:intl/intl.dart';

class ScheduleModel {
  final String bookingId;
  final String subject;
  final String bookingDateStartTime;
  final String bookingDay;
  final String bookingRoom;
  final String bookingLocation;
  final String bookingResource;
  final String bookingResourceId;
  final String status;
  final String Pricing;
  final int classNumber;
  final String PackageExpiry;
  final int RemainingCancellations;
  final double BookingDuration;
  final String PackageCode;

  // "PackageExpiry": "2026-04-20T00:00:00",
  //   "RemainingCancellations": 1

  ScheduleModel({
    required this.bookingId,
    required this.subject,
    required this.bookingDateStartTime,
    required this.bookingDay,
    required this.bookingRoom,
    required this.bookingLocation,
    required this.bookingResource,
    required this.bookingResourceId,
    required this.PackageCode,
    required this.status,
    required this.Pricing,
    required this.classNumber,
    required this.PackageExpiry,
    required this.RemainingCancellations,
    required this.BookingDuration,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      bookingId: json['BookingID'] ?? '',
      subject: json['SubjectUpdated'] ?? json['Subject'] ?? '',
      bookingDateStartTime: json['BookingDateStartTime'] ?? '',
      bookingDay: json['BookingDay'] ?? '',
      bookingRoom: json['BookingRoom'] ?? '',
      bookingLocation: json['BookingLocation'] ?? '',
      bookingResource: json['BookingResource'] ?? '',
      bookingResourceId: json['BookingResourceID'] ?? '',
      status: json['Status'] ?? '',
      PackageCode: json['PackageCode'] ?? "0",
      Pricing: json['Pricing'] ?? '',
      classNumber: json['ClassNumber'] ?? 0,
      PackageExpiry: json['PackageExpiry'] ?? "",
      BookingDuration: (json['BookingDuration'] as num?)?.toDouble() ?? 0.0,
      RemainingCancellations: json['RemainingCancellations'] ?? 0,
    );
  }

  /// ✅ SAFE DateTime parsing
  DateTime? get bookingDateTime {
    if (bookingDateStartTime.isEmpty) return null;

    try {
      return DateFormat('dd/MM/yyyy hh:mm a').parse(bookingDateStartTime);
    } catch (_) {
      return null;
    }
  }

  int get durationInMinutes => (BookingDuration * 60).round();

  // date time parse for pacakge expriy

  DateTime? get PackageExpiryDateTime {
    if (PackageExpiry.isEmpty) return null;

    try {
      return DateFormat('dd/MM/yyyy hh:mm a').parse(PackageExpiry);
    } catch (e) {
      print('error $e');
      return null;
    }
  }

  /// ✅ "Nov"
  String get monthShort {
    final dt = bookingDateTime;
    if (dt == null) return '--';
    return DateFormat('MMM').format(dt);
  }

  /// ✅ "05"
  String get day {
    final dt = bookingDateTime;
    if (dt == null) return '--';
    return DateFormat('dd').format(dt);
  }

  /// ✅ "03:30 PM"
  String get time {
    final dt = bookingDateTime;
    if (dt == null) return '--';
    return DateFormat('hh:mm a').format(dt);
  }
}
