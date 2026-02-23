// class ServiceModel {
//   final String sharedserviceid;
//   final String servicenumber;
//   final String serviceid;
//   final String service; // "Panpipe Private Class", "Piano Private Class", ...
//   final String priceid;
//   final num price;
//   final String packageId;
//   final String packageName; // "Standard"
//   final int frequency;
//   final String frequencytext;
//   final int duration; // 30, 45 etc
//   final String durationtext;
//   final int sessions;
//   final String sessionstext;
//   final String extensions;
//   final String cancellations;
//   final String freezings;
//   final String discount;

//   ServiceModel({
//     required this.sharedserviceid,
//     required this.servicenumber,
//     required this.serviceid,
//     required this.service,
//     required this.priceid,
//     required this.price,
//     required this.packageId,
//     required this.packageName,
//     required this.frequency,
//     required this.frequencytext,
//     required this.duration,
//     required this.durationtext,
//     required this.sessions,
//     required this.sessionstext,
//     required this.extensions,
//     required this.cancellations,
//     required this.freezings,
//     required this.discount,
//   });

//   factory ServiceModel.fromJson(Map<String, dynamic> j) {
//     // final priceVal =
//     // final price = priceVal is int
//     //     ? priceVal
//     //     : (priceVal is String ? int.tryParse(priceVal) ?? 0 : 0);
//     final dynamic priceRaw = j['price'];
//     num priceValue;
//     if (priceRaw == null) {
//       priceValue = 0;
//     } else if (priceRaw is num) {
//       priceValue = priceRaw;
//     } else if (priceRaw is String) {
//       // try parse as int/double
//       priceValue = num.tryParse(priceRaw) ?? 0;
//     } else {
//       priceValue = 0;
//     }
//     return ServiceModel(
//       sharedserviceid: j['sharedserviceid']?.toString() ?? '',
//       servicenumber: j['servicenumber']?.toString() ?? '',
//       serviceid: j['serviceid']?.toString() ?? '',
//       service: j['service']?.toString() ?? '',
//       priceid: j['priceid']?.toString() ?? '',
//       price: priceValue,
//       //  (j['price'] is int)
//       //     ? j['price'] as int
//       //     : int.tryParse(j['price']?.toString() ?? '0') ?? 0,
//       packageId: j['packageid']?.toString() ?? '',
//       packageName: j['package']?.toString() ?? '',
//       frequency: (j['frequency'] is int)
//           ? j['frequency'] as int
//           : int.tryParse(j['frequency']?.toString() ?? '0') ?? 0,
//       frequencytext: j['frequencytext']?.toString() ?? '',
//       duration: (j['duration'] is int)
//           ? j['duration'] as int
//           : int.tryParse(j['duration']?.toString() ?? '0') ?? 0,
//       durationtext: j['durationtext']?.toString() ?? '',
//       sessions: (j['sessions'] is int)
//           ? j['sessions'] as int
//           : int.tryParse(j['sessions']?.toString() ?? '0') ?? 0,
//       sessionstext: j['sessionstext']?.toString() ?? '',
//       extensions: j['extensions']?.toString() ?? '',
//       //  (j['extensions'] is int)
//       //     ? j['extensions'] as int
//       //     : int.tryParse(j['extensions']?.toString() ?? '0') ?? 0,
//       cancellations: j['cancellations']?.toString() ?? '',
//       //  (j['cancellations'] is int)
//       //     ? j['cancellations'] as int
//       //     : int.tryParse(j['cancellations']?.toString() ?? '0') ?? 0,
//       freezings: j['freezings']?.toString() ?? '',
//       //  (j['freezings'] is int)
//       //     ? j['freezings'] as int
//       //     : int.tryParse(j['freezings']?.toString() ?? '0') ?? 0,
//       discount: j['discount']?.toString() ?? '',
//     );
//   }
// }
