class Package {
  final String itemName;
  final String locationName;
  final String clientId;
  final String packageStatus;
  final String subject;
  final num totalClasses;
  final num remainingSessions;
  final num totalBooked;
  final num totalAllowedCancellation;
  final num remainingCancellations;
  final num totalAllowedFreezings;
  final num totalFreezingTaken;
  final String packageExpiry;
  final String classFrequency;
  final String classDuration;
  final String resource; // Teacher name and code
  final String paymentRef;
  final String branch;
  final num remainingExtension;
  final String danceOrMusic;
  final num packageRemainingPaidRecovery;
  final String serviceandproduct;
  final num packageRemainingPaidExtension;

  Package({
    required this.itemName,
    required this.locationName,
    required this.subject,
    required this.packageStatus,
    required this.totalClasses,
    required this.remainingSessions,
    required this.totalBooked,
    required this.clientId,
    required this.totalAllowedCancellation,
    required this.remainingCancellations,
    required this.totalAllowedFreezings,
    required this.totalFreezingTaken,
    required this.packageExpiry,
    required this.classFrequency,
    required this.classDuration,
    required this.resource,
    required this.paymentRef,
    required this.branch,
    required this.remainingExtension,
    required this.danceOrMusic,
    required this.serviceandproduct,
    required this.packageRemainingPaidExtension,
    required this.packageRemainingPaidRecovery,
  });

  // Factory constructor to create a Package from the API JSON Map
  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      itemName: json['Packages[Item Name]'] ?? 'Unknown Class',
      locationName: json['Packages[LocationName]'] ?? 'Unknown Location',
      packageStatus: json['Packages[Package Status]'] ?? 'Unknown',
      totalClasses: json['Packages[Total Classes]'] ?? 0,
      remainingSessions: json['Packages[Remaining Sessions]'] ?? 0,
      totalBooked: json['Packages[Total Booked]'] ?? 0,
      subject: json['Packages[Subject]'] ?? "",
      clientId: json['Packages[ClientID]'] ?? '',
      remainingExtension: json["Packages[Remaining Extension]"] ?? 0,
      totalAllowedCancellation:
          json['Packages[Total Allowed Cancellation]'] ?? 0,
      paymentRef: json['Packages[Pmt_Ref]'] ?? "",
      branch: json['Packages[LocationName]'] ?? "",
      serviceandproduct: json['Packages[Service/Product]'] ?? "",
      remainingCancellations: json['Packages[Remaining Cancellations]'] ?? 0,
      totalAllowedFreezings: json['Packages[Total Allowed Freezings]'] ?? 0,
      totalFreezingTaken: json['Packages[Total Freezing Taken]'] ?? 0,
      packageExpiry: json['Packages[Package Expiry]'] ?? 'N/A',
      classFrequency: json['Packages[Class Frequency]'] ?? 'N/A',
      classDuration: json['Packages[Class Duration]'] ?? 'N/A',
      resource: json['Packages[Resource]'] ?? 'N/A',
      danceOrMusic: json['Packages[Dance/Music]'] ?? "",

      packageRemainingPaidRecovery:
          json['Packages[Remaining Paid Recovery]'] ?? 0.0,
      packageRemainingPaidExtension:
          json['Packages[Remaining Paid Extension]'] ?? 0.0,
    );
  }

  // Helper method to extract just the teacher's name
  String get teacherName {
    final parts = resource.split('(');
    return parts.isNotEmpty ? parts[0].trim() : 'Unknown Teacher';
  }
}
