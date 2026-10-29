import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranAppSettings extends ChangeNotifier {
  QuranAppSettings._();

  static final QuranAppSettings instance = QuranAppSettings._();

  static const defaultArabicFontSize = 26.0;
  static const defaultLanguage = 'English';
  static const defaultTranslation = 'en.sahih';
  static const defaultTheme = 'system';
  static const defaultTextColor = 0xFFFFFFFF;
  static const defaultPageStyle = 'Translation view';
  static const defaultAudioSpeed = 1.0;
  static const defaultRepeatAyah = false;
  static const defaultAutoNextAyah = true;
  static const defaultReminderEnabled = false;
  static const defaultReminderMinute = 8 * 60;

  static const _prefix = 'quran_settings_';
  static const _keys = [
    'arabic_font_size',
    'arabic_font',
    'language',
    'translation',
    'page_style',
    'theme',
    'text_color',
    'audio_speed',
    'repeat_ayah',
    'auto_next_ayah',
    'reminder_enabled',
    'reminder_minute',
  ];

  double arabicFontSize = defaultArabicFontSize;
  String arabicFont = 'System default';
  String language = defaultLanguage;
  String translation = defaultTranslation;
  String pageStyle = defaultPageStyle;
  String theme = defaultTheme;
  int textColor = defaultTextColor;
  double audioSpeed = defaultAudioSpeed;
  bool repeatAyah = defaultRepeatAyah;
  bool autoNextAyah = defaultAutoNextAyah;
  bool reminderEnabled = defaultReminderEnabled;
  int reminderMinute = defaultReminderMinute;

  Future<void>? _loadFuture;

  Future<void> load() {
    return _loadFuture ??= _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    arabicFontSize =
        prefs.getDouble('${_prefix}arabic_font_size') ?? defaultArabicFontSize;
    arabicFont = prefs.getString('${_prefix}arabic_font') ?? 'System default';
    language = prefs.getString('${_prefix}language') ?? defaultLanguage;
    translation =
        prefs.getString('${_prefix}translation') ?? defaultTranslation;
    pageStyle = prefs.getString('${_prefix}page_style') ?? defaultPageStyle;
    theme = prefs.getString('${_prefix}theme') ?? defaultTheme;
    textColor = prefs.getInt('${_prefix}text_color') ?? defaultTextColor;
    audioSpeed = prefs.getDouble('${_prefix}audio_speed') ?? defaultAudioSpeed;
    repeatAyah = prefs.getBool('${_prefix}repeat_ayah') ?? defaultRepeatAyah;
    autoNextAyah =
        prefs.getBool('${_prefix}auto_next_ayah') ?? defaultAutoNextAyah;
    reminderEnabled =
        prefs.getBool('${_prefix}reminder_enabled') ?? defaultReminderEnabled;
    reminderMinute =
        prefs.getInt('${_prefix}reminder_minute') ?? defaultReminderMinute;
    notifyListeners();
  }

  Future<void> setArabicFontSize(double value) =>
      _saveDouble('arabic_font_size', value, () => arabicFontSize = value);
  Future<void> setArabicFont(String value) =>
      _saveString('arabic_font', value, () => arabicFont = value);
  Future<void> setLanguage(String value) async {
    language = value;
    translation = value == 'Urdu' ? 'ur.jalandhry' : 'en.sahih';
    await _saveValues({'language': language, 'translation': translation});
  }

  Future<void> setTranslation(String value) async {
    translation = value;
    language = value == 'ur.jalandhry' ? 'Urdu' : 'English';
    await _saveValues({'translation': translation, 'language': language});
  }

  Future<void> setPageStyle(String value) =>
      _saveString('page_style', value, () => pageStyle = value);
  Future<void> setTheme(String value) =>
      _saveString('theme', value, () => theme = value);
  Future<void> setTextColor(int value) =>
      _saveInt('text_color', value, () => textColor = value);
  Future<void> setAudioSpeed(double value) =>
      _saveDouble('audio_speed', value, () => audioSpeed = value);
  Future<void> setRepeatAyah(bool value) =>
      _saveBool('repeat_ayah', value, () => repeatAyah = value);
  Future<void> setAutoNextAyah(bool value) =>
      _saveBool('auto_next_ayah', value, () => autoNextAyah = value);
  Future<void> setReminderEnabled(bool value) =>
      _saveBool('reminder_enabled', value, () => reminderEnabled = value);
  Future<void> setReminderMinute(int value) =>
      _saveInt('reminder_minute', value, () => reminderMinute = value);

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _keys) {
      await prefs.remove('$_prefix$key');
    }
    arabicFontSize = defaultArabicFontSize;
    arabicFont = 'System default';
    language = defaultLanguage;
    translation = defaultTranslation;
    pageStyle = defaultPageStyle;
    theme = defaultTheme;
    textColor = defaultTextColor;
    audioSpeed = defaultAudioSpeed;
    repeatAyah = defaultRepeatAyah;
    autoNextAyah = defaultAutoNextAyah;
    reminderEnabled = defaultReminderEnabled;
    reminderMinute = defaultReminderMinute;
    notifyListeners();
  }

  Future<void> _saveString(
    String key,
    String value,
    void Function() update,
  ) async {
    update();
    await _saveValues({key: value});
  }

  Future<void> _saveDouble(
    String key,
    double value,
    void Function() update,
  ) async {
    update();
    await _saveValues({key: value});
  }

  Future<void> _saveInt(String key, int value, void Function() update) async {
    update();
    await _saveValues({key: value});
  }

  Future<void> _saveBool(String key, bool value, void Function() update) async {
    update();
    await _saveValues({key: value});
  }

  Future<void> _saveValues(Map<String, Object> values) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in values.entries) {
      final key = '$_prefix${entry.key}';
      final value = entry.value;
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    }
    notifyListeners();
  }

  ThemeMode get themeMode => switch (theme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
