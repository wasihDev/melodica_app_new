class CountryCode {
  final String mcCountryCodeId;
  final String mcName;
  final int? mcLength;
  final String? countryName;

  CountryCode({
    required this.mcCountryCodeId,
    required this.mcName,
    required this.mcLength,
    this.countryName,
  });

  factory CountryCode.fromJson(Map<String, dynamic> json) {
    return CountryCode(
      mcCountryCodeId: json['@odata.etag'] as String? ?? '',
      mcName:
          json['displayorder@OData.Community.Display.V1.FormattedValue']
              as String? ??
          '',
      mcLength: json['displayorder'] is int
          ? json['displayorder'] as int
          : (json['displayorder'] is String
                ? int.tryParse(json['displayorder'])
                : null),
      countryName: json['attributevalue'] != null
          ? (json['attributevalue']['attributevalue'] as String?)
          : null,
    );
  }
}
