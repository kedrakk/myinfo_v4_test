import 'package:shared_preferences/shared_preferences.dart';

class SFHelper {
  Future<void> storeString({
    required String key,
    required String value,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
  }

  Future<String?> getString({
    required String key,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }
}

class SFKeys {
  final String codeVerifier = "code_verifier";
}
