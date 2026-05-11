import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static late SharedPreferences _prefs;

  static const String _currencyKey = 'currency_symbol';
  static const String _themeKey = 'theme_mode';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getCurrency() {
    return _prefs.getString(_currencyKey) ?? 'ETB';
  }

  Future<void> setCurrency(String symbol) async {
    await _prefs.setString(_currencyKey, symbol);
  }

  String getTheme() {
    return _prefs.getString(_themeKey) ?? 'light';
  }

  Future<void> setTheme(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }
}
