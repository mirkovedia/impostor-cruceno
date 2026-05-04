import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class StorageService {
  static const _keyDarkMode = 'dark_mode';
  static const _keyThemeType = 'theme_type';
  static const _keySound = 'sound_enabled';
  static const _keyVibration = 'vibration_enabled';
  static const _keyDefaultRoundTime = 'default_round_time';
  static const _keyDefaultImpostors = 'default_impostors';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyReminderDay = 'reminder_day';
  static const _keyReminderHour = 'reminder_hour';

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

  bool get isNotificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? false;
  set isNotificationsEnabled(bool value) =>
      _prefs.setBool(_keyNotificationsEnabled, value);

  // Día de la semana: 5 = viernes (DateTime.friday)
  int get reminderDay => _prefs.getInt(_keyReminderDay) ?? DateTime.friday;
  set reminderDay(int value) => _prefs.setInt(_keyReminderDay, value);

  // Hora del recordatorio (0-23), default 19:00
  int get reminderHour => _prefs.getInt(_keyReminderHour) ?? 19;
  set reminderHour(int value) => _prefs.setInt(_keyReminderHour, value);

  Future<void> resetAll() async {
    await _prefs.clear();
  }
}
