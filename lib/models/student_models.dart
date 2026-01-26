/// ---------- MODELS ----------
class Customer {
  final String source;
  final String mbId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String customerType;
  final String customerGroup;
  final String email;
  final String mbCreatedBy;
  final String mbBranch;
  final String territoryid;
  final String dateOfBirth;
  final String city;
  final String emirateId;
  final String county;
  final String areaId;
  final String overriddenCreatedOn;
  final String statuscode;
  final String gender;
  final String mobileCountryCode;
  final String mobileAreaCode;
  final String mobilePhone;
  final String customerClassification;
  final String relationship;
  final int? relationshipValue;
  final String sourcelocation;

  Customer({
    required this.source,
    required this.mbId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.customerType,
    required this.customerGroup,
    required this.email,
    required this.mbCreatedBy,
    required this.mbBranch,
    required this.territoryid,
    required this.dateOfBirth,
    required this.city,
    required this.emirateId,
    required this.county,
    required this.areaId,
    required this.overriddenCreatedOn,
    required this.statuscode,
    required this.gender,
    required this.mobileCountryCode,
    required this.mobileAreaCode,
    required this.mobilePhone,
    required this.customerClassification,
    required this.relationship,
    required this.relationshipValue,
    required this.sourcelocation,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // note: JSON keys include spaces exactly like "First Name"
    return Customer(
      source: json['Source']?.toString() ?? '',
      mbId: json['MB ID']?.toString() ?? '',
      firstName: json['First Name']?.toString() ?? '',
      lastName: json['Last Name']?.toString() ?? '',
      fullName: json['Full Name']?.toString() ?? '',
      customerType: json['Customer Type']?.toString() ?? '',
      customerGroup: json['Customer Group']?.toString() ?? '',
      email: json['Email']?.toString() ?? '',
      mbCreatedBy: json['MB Created By']?.toString() ?? '',
      mbBranch: json['MB Branch']?.toString() ?? '',
      territoryid: json['territoryid']?.toString() ?? '',
      dateOfBirth: json['Date of Birth']?.toString() ?? '',
      city: json['Address 1: City']?.toString() ?? '',
      emirateId: json['Emirate ID']?.toString() ?? '',
      county: json['Address 1: County']?.toString() ?? '',
      areaId: json['Area ID']?.toString() ?? '',
      overriddenCreatedOn: json['Overridden Created On']?.toString() ?? '',
      statuscode: json['statuscode']?.toString() ?? '',
      gender: json['Gender']?.toString() ?? '',
      mobileCountryCode: json['Mobile Phone Country Code']?.toString() ?? '',
      mobileAreaCode: json['Mobile Phone Area Code']?.toString() ?? '',
      mobilePhone: json['Mobile Phone']?.toString() ?? '',
      customerClassification: json['Customer Classification']?.toString() ?? '',
      relationship: json['Relationship']?.toString() ?? '',
      relationshipValue: json['RelationshipValue'] is int
          ? json['RelationshipValue'] as int
          : (int.tryParse(json['RelationshipValue']?.toString() ?? '') ?? 0),
      sourcelocation: json['sourcelocation']?.toString() ?? '',
    );
  }
}

class Student {
  final dynamic mbId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String dateOfBirth;
  final String emirateId;
  final String city;
  final String county;
  final String areaId;
  final String overriddenCreatedOn;
  final String statuscode;
  final String gender;
  final String guardianId;
  final String isregistred;

  Student({
    required this.mbId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.emirateId,
    required this.city,
    required this.county,
    required this.areaId,
    required this.overriddenCreatedOn,
    required this.statuscode,
    required this.gender,
    required this.guardianId,
    required this.isregistred,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      mbId: json['MB ID'],
      firstName: json['First Name']?.toString() ?? '',
      lastName: json['Last Name']?.toString() ?? '',
      fullName: json['Full Name']?.toString() ?? '',
      email: json['Email']?.toString() ?? '',
      dateOfBirth: json['Date of Birth']?.toString() ?? '',
      emirateId: json['Emirate ID']?.toString() ?? '',
      city: json['Address 1: City']?.toString() ?? '',
      county: json['Address 1: County']?.toString() ?? '',
      areaId: json['Area ID']?.toString() ?? '',
      overriddenCreatedOn: json['Overridden Created On']?.toString() ?? '',
      statuscode: json['statuscode']?.toString() ?? '',
      gender: json['Gender']?.toString() ?? '',
      guardianId: json['Guardian ID']?.toString() ?? '',
      isregistred: json['Is Registered']?.toString() ?? '',
    );
  }
}

class CustomerResponse {
  final Customer? customer;
  final List<Student> students;

  CustomerResponse({this.customer, required this.students});

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    final customerJson = json['Customer'] as Map<String, dynamic>?;
    final studentsJson = json['Students'] as List<dynamic>?;

    final customer = customerJson != null
        ? Customer.fromJson(customerJson)
        : null;
    final students = studentsJson != null
        ? studentsJson
              .map((e) => Student.fromJson(e as Map<String, dynamic>))
              .toList()
        : <Student>[];

    return CustomerResponse(customer: customer, students: students);
  }
}
