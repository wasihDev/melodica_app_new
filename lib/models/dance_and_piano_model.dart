class ServiceModel {
  final String sharedServiceId;
  final String serviceId;
  final String serviceNumber;
  final String serviceName;

  final String priceId;
  final num price;

  final String packageId;
  final String packageName;

  final int sessions;
  final String sessionsText;
  final String sessionsId;

  final int extensions;
  final int cancellations;
  final int freezings;

  final double discount;

  final String frequencyId;
  final String frequencyText;

  final int duration;
  final String durationText;

  final String subjects; // Dance only
  final bool isDance;

  ServiceModel({
    required this.sharedServiceId,
    required this.serviceId,
    required this.serviceNumber,
    required this.serviceName,
    required this.priceId,
    required this.price,
    required this.packageId,
    required this.packageName,
    required this.sessions,
    required this.sessionsText,
    required this.sessionsId,
    required this.extensions,
    required this.cancellations,
    required this.freezings,
    required this.discount,
    required this.frequencyId,
    required this.frequencyText,
    required this.duration,
    required this.durationText,
    required this.subjects,
    required this.isDance,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final dynamic priceRaw = json['price'];
    num priceValue;
    if (priceRaw == null) {
      priceValue = 0;
    } else if (priceRaw is num) {
      priceValue = priceRaw;
    } else if (priceRaw is String) {
      // try parse as int/double
      priceValue = num.tryParse(priceRaw) ?? 0;
    } else {
      priceValue = 0;
    }
    bool isDanceService =
        (json['subjects'] != null && json['subjects'].toString().isNotEmpty);

    return ServiceModel(
      sharedServiceId: json['sharedserviceid'] ?? '',
      serviceId: json['serviceid'] ?? json['globalid'] ?? '',
      serviceNumber: json['servicenumber'] ?? '',
      serviceName: json['service'] ?? '',

      priceId: json['priceid'] ?? '',
      price: priceValue,

      //double.tryParse(json['price'].toString()) ?? 0.0,
      packageId: json['packageid'] ?? '',
      packageName: json['package'] ?? '',

      sessions: int.tryParse(json['sessions'].toString()) ?? 0,
      sessionsText: json['sessionstext'] ?? '',
      sessionsId: json['sessionsid'] ?? '',

      extensions: int.tryParse(json['extensions'].toString()) ?? 0,
      cancellations: int.tryParse(json['cancellations'].toString()) ?? 0,
      freezings: int.tryParse(json['freezings'].toString()) ?? 0,

      discount: double.tryParse(json['discount'].toString()) ?? 0.0,

      frequencyId: json['frequencyid'] ?? '',
      frequencyText: json['frequencytext'] ?? '',

      duration: int.tryParse(json['duration'].toString()) ?? 0,
      durationText: json['durationtext'] ?? '',

      subjects: json['subjects'] ?? '',
      isDance: isDanceService,
    );
  }
}
