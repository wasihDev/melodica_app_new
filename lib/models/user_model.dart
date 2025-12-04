// class UserModel {
//   final String? uid;
//   final String? tokenId;
//   String? email;
//   String? name;
//   String? image;
//   String? userSubcriptionRecipt;
//   final bool? isGuest;
//   UserModel({
//     this.uid,
//     this.tokenId,
//     this.name,
//     this.email,
//     this.image,
//     this.userSubcriptionRecipt,
//     this.isGuest = false,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       uid: json['uid'] ?? '',
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       image: json['image'] ?? '',
//       tokenId: json['tokenId'] ?? "",
//       userSubcriptionRecipt: json['receiptData'] ?? "",
//       isGuest: json.containsKey('isGuest') ? json['isGuest'] as bool : false,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'uid': uid,
//       'name': name,
//       'email': email,
//       'image': image,
//       'tokenId': tokenId,
//       'receiptData': userSubcriptionRecipt,
//       "isGuest": isGuest,
//     };
//   }
// }

class UserModel {
  String? uid;

  // Basic info
  String? firstName;
  String? lastName;
  String? email;
  String? image;

  // Phone
  String? areaCode; // AREA - 971
  String? phoneCode; // 54
  String? phoneNumber; // 123 456 78

  // Personal info
  String? dateOfBirth; // "8 Feb, 2004"
  String? gender; // Male / Female

  // Extra info
  String? relation; // Mother / Father
  String? level; // Beginner / etc.
  bool? isPreviousStudent; // yes/no
  String? tokenId;

  UserModel({
    this.uid,
    this.firstName,
    this.lastName,
    this.email,
    this.tokenId,
    this.image,
    this.areaCode,
    this.phoneCode,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.relation,
    this.level,
    this.isPreviousStudent = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      image: json['image'],
      areaCode: json['areaCode'],
      phoneCode: json['phoneCode'],
      tokenId: json['tokenId'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      relation: json['relation'],
      level: json['level'],
      isPreviousStudent: json['isPreviousStudent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'image': image,
      'areaCode': areaCode,
      'phoneCode': phoneCode,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'tokenId': tokenId,
      'relation': relation,
      'level': level,
      'isPreviousStudent': isPreviousStudent,
    };
  }
}
