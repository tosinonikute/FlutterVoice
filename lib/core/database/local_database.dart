import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._internal();
  LocalDatabase._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // First time user check
  Future<bool> isFirstTimeUser() async {
    // await init();
    return _prefs.getBool('is_first_time') ?? true;
  }

  Future<void> setFirstTimeUser(bool value) async {
    // await init();
    await _prefs.setBool('is_first_time', value);
  }

  // Add more storage methods here as needed
  // Example:
  // Future<void> saveUserSettings(Map<String, dynamic> settings) async {
  //   await init();
  //   await _prefs.setString('user_settings', jsonEncode(settings));
  // }
}
