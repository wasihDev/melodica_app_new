class UserModel {
  final String? uid;
  final String? tokenId;
  String? email;
  String? name;
  String? image;
  String? userSubcriptionRecipt;
  final bool? isGuest;
  UserModel({
    this.uid,
    this.tokenId,
    this.name,
    this.email,
    this.image,
    this.userSubcriptionRecipt,
    this.isGuest = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      tokenId: json['tokenId'] ?? "",
      userSubcriptionRecipt: json['receiptData'] ?? "",
      isGuest: json.containsKey('isGuest') ? json['isGuest'] as bool : false,

      //json["isGuest"] ?? false, // 👈 fallback false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'image': image,
      'tokenId': tokenId,
      'receiptData': userSubcriptionRecipt,
      "isGuest": isGuest,
    };
  }

  // bool get isGuest => false;
}

// class GuestUser extends UserModel {
//   GuestUser()
//     : super(
//         uid: 'guest',
//         name: 'Guest',
//         email: 'guest@example.com',
//         image: "",
//         tokenId: '',
//         userSubcriptionRecipt: '',
//       );

//   @override
//   bool get isGuest => true;
// }
