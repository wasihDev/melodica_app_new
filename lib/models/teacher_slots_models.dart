class TeacherSlot {
  final String id; // <--- String
  final String firstName;
  final String lastName;
  final List<String> subjects;
  final List<String> locations;
  final String slotsType;
  final List<String> slots;
  final String fullname;
  TeacherSlot({
    required this.id,
    required this.firstName,
    required this.fullname,
    required this.lastName,
    required this.subjects,
    required this.locations,
    required this.slotsType,
    required this.slots,
  });

  factory TeacherSlot.fromJson(Map<String, dynamic> json) {
    return TeacherSlot(
      id: json['id'].toString(), // convert int or string to String
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullname: json['full_name'] ?? "",
      subjects: (json['subject'] as List<dynamic>)
          .map((s) => s['name'] as String)
          .toList(),
      locations: (json['location'] as List<dynamic>)
          .map((l) => l['name'] as String)
          .toList(),
      slotsType: json['slots_type'] ?? '',
      slots: (json['slots'] as List<dynamic>).map((s) => s as String).toList(),
    );
  }
}
