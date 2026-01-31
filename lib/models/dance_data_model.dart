// optional, add if using NumberFormat

/// ------------------ MODEL ------------------
class DanceDataModel {
  final String sharedserviceid;
  final String servicenumber;
  final String serviceid;
  final String service;
  final String priceid;
  final num price; // can be int or double
  final String packageId;
  final String packageName;
  final int? frequency;
  final String? frequencytext;
  final int? duration;
  final String? durationtext;
  final int sessions;
  final String sessionstext;
  final int? extensions;
  final int? cancellations;
  final int? freezings;
  final String discount;
  final String subject;

  DanceDataModel({
    required this.sharedserviceid,
    required this.servicenumber,
    required this.serviceid,
    required this.service,
    required this.priceid,
    required this.price,
    required this.packageId,
    required this.packageName,
    required this.frequency,
    required this.frequencytext,
    required this.duration,
    required this.durationtext,
    required this.sessions,
    required this.sessionstext,
    required this.extensions,
    required this.cancellations,
    required this.freezings,
    required this.discount,
    required this.subject,
  });

  factory DanceDataModel.fromJson(Map<String, dynamic> j) {
    // robust price parsing (handles int, double, numeric string)
    final dynamic priceRaw = j['price'];
    num priceValue;
    if (priceRaw == null) {
      priceValue = 0;
    } else if (priceRaw is num) {
      priceValue = priceRaw;
    } else if (priceRaw is String) {
      priceValue = num.tryParse(priceRaw) ?? 0;
    } else {
      priceValue = 0;
    }

    int? tryInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return DanceDataModel(
      sharedserviceid: j['sharedserviceid']?.toString() ?? '',
      servicenumber: j['servicenumber']?.toString() ?? '',
      serviceid: j['serviceid']?.toString() ?? '',
      service: j['service']?.toString() ?? '',
      priceid: j['priceid']?.toString() ?? '',
      discount: j['discount']?.toString() ?? '',
      price: priceValue,
      packageId: j['packageid']?.toString() ?? '',
      packageName: j['package']?.toString() ?? '',
      frequency: tryInt(j['frequency']),
      frequencytext: j['frequencytext']?.toString(),
      duration: tryInt(j['duration']),
      durationtext: j['durationtext']?.toString(),
      sessions: tryInt(j['sessions']) ?? 0,
      sessionstext: j['sessionstext']?.toString() ?? '',
      extensions: tryInt(j['extensions']),
      cancellations: tryInt(j['cancellations']),
      freezings: tryInt(j['freezings']),
      subject: j['subjects'] ?? "",
    );
  }
}
