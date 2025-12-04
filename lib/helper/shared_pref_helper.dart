import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _authTokenKey = 'auth_tokenID';

  // Save token
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  // Get token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Remove token
  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final remv = await prefs.remove(_authTokenKey);
    prefs.remove('ios_receipt');
    prefs.remove('active_subscription_id');
    prefs.remove('subscription_start_date');
    print('token id Remove $remv');
  }
}
