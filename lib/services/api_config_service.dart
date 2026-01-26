import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melodica_app_new/models/api_endpoints_model.dart';

class ApiConfigService {
  static ApiEndpoints? _endpoints;

  static ApiEndpoints get endpoints {
    if (_endpoints == null) {
      throw Exception('API endpoints not initialized');
    }
    return _endpoints!;
  }

  static Future<void> load() async {
    final uri = Uri.parse(
      'https://prod-199.westeurope.logic.azure.com/workflows/47e602f17da746cc9ed04392d4f3db70/triggers/manual/paths/invoke?api-version=2016-06-01&sp=/triggers/manual/run&sv=1.0&sig=60drjf5Fiu7VHXH3KFPbXjV9y9CTuyAgiHXkzDlkqgU',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load API config');
    }

    final body = json.decode(response.body);
    _endpoints = ApiEndpoints.fromJson(body);
  }
}
