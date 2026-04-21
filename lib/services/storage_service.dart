import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class StorageService {
  static const _keyDarkMode = 'dark_mode';
  static const _keyThemeType = 'theme_type';
  static const _keySound = 'sound_enabled';
  static const _keyVibration = 'vibration_enabled';
  static const _keyDefaultRoundTime = 'default_round_time';
  static const _keyDefaultImpostors = 'default_impostors';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? true;
  set isDarkMode(bool value) => _prefs.setBool(_keyDarkMode, value);

  AppThemeType get themeType {
    final index = _prefs.getInt(_keyThemeType);
    if (index == null || index >= AppThemeType.values.length) {
      return AppThemeType.cruceno;
    }
    return AppThemeType.values[index];
  }

  set themeType(AppThemeType value) =>
      _prefs.setInt(_keyThemeType, value.index);

  bool get isSoundEnabled => _prefs.getBool(_keySound) ?? true;
  set isSoundEnabled(bool value) => _prefs.setBool(_keySound, value);

  bool get isVibrationEnabled => _prefs.getBool(_keyVibration) ?? true;
  set isVibrationEnabled(bool value) => _prefs.setBool(_keyVibration, value);

  int get defaultRoundTime => _prefs.getInt(_keyDefaultRoundTime) ?? 90;
  set defaultRoundTime(int value) => _prefs.setInt(_keyDefaultRoundTime, value);

  int get defaultImpostors => _prefs.getInt(_keyDefaultImpostors) ?? 1;
  set defaultImpostors(int value) =>
      _prefs.setInt(_keyDefaultImpostors, value);

  Future<void> resetAll() async {
    await _prefs.clear();
  }
}
