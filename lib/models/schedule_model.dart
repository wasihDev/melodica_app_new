import 'package:intl/intl.dart';

class ScheduleModel {
  final String bookingId;
  final String ClientID;
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
  final String danceOrMusic;
  final String LastClass;
  final String BookingEndTime;
  // "PackageExpiry": "2026-04-20T00:00:00",
  //   "RemainingCancellations": 1

  ScheduleModel({
    required this.bookingId,
    required this.subject,
    required this.ClientID,
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
    required this.danceOrMusic,
    required this.LastClass,
    required this.BookingEndTime,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    // print('json --->>>>  $json');
    return ScheduleModel(
      bookingId: json['BookingID'] ?? '',
      subject: json['SubjectUpdated'] ?? json['Subject'] ?? '',
      bookingDateStartTime: json['BookingDateStartTime'] ?? '',
      bookingDay: json['BookingDay'] ?? '',
      ClientID: json['ClientID'] ?? "",
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
      danceOrMusic: json['DanceOrMusic'] ?? "",
      LastClass: json['LastClass'] ?? "",
      BookingEndTime: json['BookingEndTime'] ?? "",
    );
  }

  /// ✅ SAFE DateTime parsing
  DateTime? get bookingDateTime {
    if (bookingDateStartTime.isEmpty) return null;

    try {
      return DateFormat('d MMM yyyy h:mm a').parseLoose(bookingDateStartTime);
    } catch (e) {
      print('bookingDate error $e');
      return null;
    }
  }

  /// ✅ SAFE DateTime parsing
  // DateTime? get Bookingtime {
  //   if (BookingEndTime.isEmpty) return null;

  //   try {
  //     return DateFormat('d MMM yyyy h:mm a').parseLoose(BookingEndTime);
  //   } catch (e) {
  //     print('bookingDate error $e');
  //     return null;
  //   }
  // }
  DateTime? get Bookingtime {
    if (BookingEndTime.isEmpty) return null;
    try {
      // 1. Convert "1899-12-30t16:30:00" to "1899-12-30T16:30:00" (uppercase T)
      // 2. DateTime.parse handles ISO 8601 automatically
      return DateTime.parse(BookingEndTime.toUpperCase());
    } catch (e) {
      // If it's not ISO, try your original format as a fallback
      try {
        return DateFormat('d MMM yyyy h:mm a').parseLoose(BookingEndTime);
      } catch (innerError) {
        print('bookingDate error $innerError');
        return null;
      }
    }
  }

  int get durationInMinutes => (BookingDuration * 60).round();

  // date time parse for pacakge expriy

  DateTime? get PackageExpiryDateTime {
    if (PackageExpiry.isEmpty) return null;

    try {
      return DateFormat('d MMM yyyy hh:mm a').parse(PackageExpiry);
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
    return DateFormat('d').format(dt);
  }

  /// ✅ "03:30 PM"
  // String get time {
  //   final be = BookingEndTime;
  //   final dt = bookingDateTime;
  //   if (dt == null) return '--';
  //   return DateFormat('h:mm a').format(dt);
  // }
  String get time {
    final start = bookingDateTime;
    final end = Bookingtime;

    if (start == null || end == null) return '--';

    final String startTime = DateFormat('h:mm a').format(start);
    final String endTime = DateFormat('h:mm a').format(end);

    return '$startTime - $endTime';
  }
}
