class FreezingSeason {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String max;
  final String fourClasses;
  FreezingSeason({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.max,
    required this.fourClasses,
  });

  factory FreezingSeason.fromJson(Map<String, dynamic> json) {
    return FreezingSeason(
      name: json['Name'] ?? '',
      startDate: DateTime.parse(json['Start Date']),
      endDate: DateTime.parse(json['End Date']),
      status: json['Status'] ?? '',
      max: json['Max'] ?? "",
      fourClasses: json['4 Classes'] ?? "",
    );
  }
}
