class CountryCodeModel {
  final String name;
  final int callingCode;
  final bool requiresAreaCode;
  final int maxnumber;
  final String countryName;

  CountryCodeModel({
    required this.name,
    required this.callingCode,
    required this.requiresAreaCode,
    required this.maxnumber,
    required this.countryName,
  });

  factory CountryCodeModel.fromJson(Map<String, dynamic> json) {
    return CountryCodeModel(
      name: json['mc_name'] ?? '',
      maxnumber: json['mc_length'] ?? 0,
      callingCode: json['mc_callingcode'] ?? 0,
      countryName: json['mc_Country']?['mc_name'] ?? '',
      requiresAreaCode: json['mc_requiresareacode'] ?? false,
    );
  }
}

class AreaCodeModel {
  final String value;

  AreaCodeModel({required this.value});

  factory AreaCodeModel.fromJson(Map<String, dynamic> json) {
    return AreaCodeModel(value: json['value'].toString());
  }
}
