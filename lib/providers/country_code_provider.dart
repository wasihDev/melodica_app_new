import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:melodica_app_new/models/country_code.dart';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/services/api_config_service.dart';

class CountryCodeProvider extends ChangeNotifier {
  // final String apiUrl;
  CountryCodeProvider() {
    fetch();
  }

  List<CountryCode> _items = [];
  List<CountryCode> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  int? _selectedLength; // currently selected attribute (mc_length)
  int? get selectedLength => _selectedLength;

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        "${ApiConfigService.endpoints.getCountryCodes}",
        //'https://bf67c0337b6de47faeee4735e1fe49.46.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/8ee946d1c431472b9c2a1113779d78f1/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ioiQ0gmozlMobMHg2BAdP-sObkewvfRCdAykliq0LJE',
      );
      final resp = await http.get(
        uri,
        headers: {'api-key': "60e35fdc-401d-494d-9d78-39b15e345547"},
      );
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }
      print('resp ${resp.statusCode}');
      final Map<String, dynamic> jsonResp =
          json.decode(resp.body) as Map<String, dynamic>;
      // print('jsonResp ${jsonResp}');
      // adapt to your JSON root key
      final dynamic arr = jsonResp['areacodes'];
      if (arr == null || arr is! List) {
        _items = [];
        _error = 'No countrycodes found in response';
      } else {
        _items = (arr as List)
            .map((e) => CountryCode.fromJson(e as Map<String, dynamic>))
            .toList();
        // if there is at least one and mc_length exists, set default selection
        final firstWithLength = _items.firstWhere(
          (e) => e.mcLength != null,
          orElse: () => _items.isNotEmpty
              ? _items.first
              : CountryCode(mcCountryCodeId: '', mcName: '', mcLength: null),
        );
        _selectedLength = firstWithLength.mcLength;
      }
    } catch (e) {
      _error = 'Failed to load: $e';
      _items = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSelectedLength(int? v) {
    _selectedLength = v;
    notifyListeners();
  }

  /// helper to find the CountryCode by length (if needed)
  CountryCode? findByLength(int length) {
    return _items.firstWhere(
      (e) => e.mcLength == length,
      orElse: () {
        return CountryCode(mcCountryCodeId: '', mcName: '', mcLength: 1);
      },
    );
  }
}
