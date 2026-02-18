import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global singleton accessor
late LanguageManager languageManager;

class LanguageManager extends ChangeNotifier {
  static const String _prefKey = 'app_language';
  static const Locale _defaultLocale = Locale('en');

  Locale _locale = _defaultLocale;
  final SharedPreferences _prefs;

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  LanguageManager._(this._prefs);

  /// Factory that loads saved preference
  static Future<LanguageManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    final manager = LanguageManager._(prefs);
    final saved = prefs.getString(_prefKey);
    if (saved != null && (saved == 'ar' || saved == 'en')) {
      manager._locale = Locale(saved);
    }
    languageManager = manager;
    return manager;
  }

  /// Toggle between Arabic and English
  void toggleLanguage() {
    setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }

  /// Set a specific locale
  void setLocale(Locale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    _prefs.setString(_prefKey, newLocale.languageCode);
    notifyListeners();
  }
}

/// Custom localizations class that loads JSON translation files
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Future<bool> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

/// Extension for cleaner syntax: context.tr('key')
extension TranslationExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}

/// Localization delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
