import 'package:shared_preferences/shared_preferences.dart';

class LocalSharedPreferences {
  static final LocalSharedPreferences _instancia =
      LocalSharedPreferences.internal();

  factory LocalSharedPreferences() {
    return _instancia;
  }

  LocalSharedPreferences.internal();

  static late SharedPreferences _prefs;

  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static clear() async {
    _prefs.clear();
  }

  String get userID {
    return _prefs.getString('userID') ?? '';
  }

  set userID(String value) {
    _prefs.setString('userID', value);
  }

  static String get lenguage {
    return _prefs.getString('lenguage') ?? 'es';
  }

  static set lenguage(String value) {
    _prefs.setString('lenguage', value);
  }

  String get token {
    return _prefs.getString('token') ?? '';
  }

  set token(String value) {
    _prefs.setString('token', value);
  }

  bool get isLogged {
    return _prefs.getBool('isLogged') ?? false;
  }

  set isLogged(bool value) {
    _prefs.setBool('isLogged', value);
  }

  bool get isFirstTime {
    return _prefs.getBool('isFirstTime') ?? true;
  }

  set isFirstTime(bool value) {
    _prefs.setBool('isFirstTime', value);
  }
}
